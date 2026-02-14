local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage.Shared.Framework.Util)
local Objectives = require(ReplicatedStorage.Shared.Data.Objectives)
local Net = require(ReplicatedStorage.Shared.Framework.Net)

local ObjectiveService = {}
ObjectiveService.__index = ObjectiveService

function ObjectiveService.new(services)
    local self = setmetatable({}, ObjectiveService)
    self.Services = services
    self.Graph = {}
    self.PlayerSpeedScale = {}
    return self
end

function ObjectiveService:Init()
    Net.Get("ObjectiveRequest").OnServerEvent:Connect(function(player, payload)
        if not Net.IsAllowed(player, "ObjectiveRequest") then
            return
        end
        self:HandleObjectiveRequest(player, payload)
    end)
end

function ObjectiveService:GenerateObjectiveGraph(spawnNodes)
    local objectiveTypes = {}
    for objectiveId in pairs(Objectives) do
        table.insert(objectiveTypes, objectiveId)
    end
    Util.Shuffle(objectiveTypes)

    self.Graph = {}
    for i, node in ipairs(spawnNodes) do
        local objectiveId = objectiveTypes[((i - 1) % #objectiveTypes) + 1]
        local cfg = Objectives[objectiveId]
        table.insert(self.Graph, {
            id = Util.GenerateId("obj"),
            objectiveType = objectiveId,
            stage = 1,
            maxStage = cfg.stages,
            node = node,
            complete = false,
        })
    end

    Net.SendToAll("Replication", { type = "ObjectiveGraph", objectives = self.Graph })
end

function ObjectiveService:HandleObjectiveRequest(player, payload)
    local objective = self.Graph[payload.index]
    if not objective or objective.complete then
        return
    end

    objective.stage += 1
    if objective.stage > objective.maxStage then
        objective.complete = true
        self.Services.PerkEngine:Trigger(player, "OnObjectiveComplete", self.Services)
    end

    Net.SendToAll("Replication", { type = "ObjectiveUpdate", objective = objective })
    if self:IsGraphComplete() then
        self.Services.MatchService:UnlockEscapeGates()
    end
end

function ObjectiveService:IsGraphComplete()
    for _, objective in ipairs(self.Graph) do
        if not objective.complete then
            return false
        end
    end
    return #self.Graph > 0
end

function ObjectiveService:ApplyObjectiveSpeed(player, mult)
    self.PlayerSpeedScale[player] = mult
end

return ObjectiveService
