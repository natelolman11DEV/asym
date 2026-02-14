local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Framework.Net)

local ReplicationController = {}
ReplicationController.__index = ReplicationController

function ReplicationController.new(controllers)
    return setmetatable({ Controllers = controllers, Cache = {} }, ReplicationController)
end

function ReplicationController:Init()
    Net.Get("Replication").OnClientEvent:Connect(function(payload)
        if payload.type == "ObjectiveGraph" then
            self.Cache.Objectives = payload.objectives
            self.Controllers.UIController:UpdateObjectives(payload.objectives)
        elseif payload.type == "ObjectiveUpdate" then
            self.Controllers.UIController:UpdateObjective(payload.objective)
        elseif payload.type == "HealthState" then
            self.Cache[payload.playerId] = payload.state
        end
    end)

    Net.Get("MatchStateChanged").OnClientEvent:Connect(function(payload)
        self.Controllers.UIController:OnMatchState(payload.newState)
    end)

    Net.Get("UIMessage").OnClientEvent:Connect(function(payload)
        self.Controllers.UIController:PushMessage(payload)
    end)
end

return ReplicationController
