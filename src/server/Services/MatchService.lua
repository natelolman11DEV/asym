local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateMachine = require(ReplicatedStorage.Shared.Framework.StateMachine)
local Net = require(ReplicatedStorage.Shared.Framework.Net)

local MatchService = {}
MatchService.__index = MatchService

local STATES = {
    Lobby = "Lobby",
    Intermission = "Intermission",
    RoleAssignment = "RoleAssignment",
    IntroCutscene = "IntroCutscene",
    ActiveMatch = "ActiveMatch",
    EndgameCollapse = "EndgameCollapse",
    ResultsScreen = "ResultsScreen",
    ReturnToLobby = "ReturnToLobby",
}

function MatchService.new(services)
    local self = setmetatable({}, MatchService)
    self.Services = services
    self.Machine = StateMachine.new({
        initial = STATES.Lobby,
        transitions = {
            Lobby = { STATES.Intermission },
            Intermission = { STATES.RoleAssignment },
            RoleAssignment = { STATES.IntroCutscene },
            IntroCutscene = { STATES.ActiveMatch },
            ActiveMatch = { STATES.EndgameCollapse, STATES.ResultsScreen },
            EndgameCollapse = { STATES.ResultsScreen },
            ResultsScreen = { STATES.ReturnToLobby },
            ReturnToLobby = { STATES.Lobby },
        },
    })
    self.CollapseEndTime = 0
    return self
end

function MatchService:Init()
    self.Machine.Changed:Connect(function(oldState, newState)
        Net.SendToAll("MatchStateChanged", { oldState = oldState, newState = newState })
    end)

    Net.Get("InputState").OnServerEvent:Connect(function(player, payload)
        if Net.IsAllowed(player, "InputState") then
            self.Services.PlayerStateService:ApplyInputState(player, payload)
        end
    end)

    Net.Get("LoadoutRequest").OnServerInvoke = function(player, payload)
        local profile = self.Services.DataService.Cache[player.UserId]
        if payload and payload.mode == "Get" then
            return profile and profile.loadout
        end
        if payload and payload.mode == "Set" and profile then
            profile.loadout = payload.loadout
            return true
        end
        return false
    end

    task.spawn(function()
        while true do
            self:RunLoop()
        end
    end)
end

function MatchService:RunLoop()
    self.Machine:Transition(STATES.Intermission)
    task.wait(5)
    self.Machine:Transition(STATES.RoleAssignment)
    self:AssignRoles()
    task.wait(2)
    self.Machine:Transition(STATES.IntroCutscene)
    task.wait(4)
    self.Machine:Transition(STATES.ActiveMatch)
    self.Services.ObjectiveService:GenerateObjectiveGraph(self:GetObjectiveSpawnNodes())
    task.wait(120)
    if self.Machine:GetState() == STATES.ActiveMatch then
        self:StartEndgameCollapse(60)
    end
    task.wait(60)
    self.Machine:Transition(STATES.ResultsScreen)
    self:DistributeResults()
    task.wait(8)
    self.Machine:Transition(STATES.ReturnToLobby)
    task.wait(2)
    self.Machine:Transition(STATES.Lobby)
end

function MatchService:AssignRoles()
    local players = Players:GetPlayers()
    if #players == 0 then
        return
    end
    local killerIndex = math.random(1, #players)

    for i, player in ipairs(players) do
        local role = i == killerIndex and "Killer" or "Survivor"
        local profile = self.Services.DataService.Cache[player.UserId]
        self.Services.PlayerStateService:SetRole(player, role)

        if role == "Killer" then
            self.Services.KillerService:SpawnKiller(player, "MrDeadAir")
        elseif profile and profile.loadout then
            self.Services.PerkEngine:Equip(player, profile.loadout.perks)
        end
    end
end

function MatchService:GetObjectiveSpawnNodes()
    local folder = workspace:FindFirstChild("ObjectiveNodes")
    if not folder then
        return { CFrame.new(0, 0, 0), CFrame.new(20, 0, 20), CFrame.new(-20, 0, 20) }
    end
    local nodes = {}
    for _, part in ipairs(folder:GetChildren()) do
        if part:IsA("BasePart") then
            table.insert(nodes, part.CFrame)
        end
    end
    return nodes
end

function MatchService:UnlockEscapeGates()
    Net.SendToAll("UIMessage", { type = "EscapeGateUnlocked" })
end

function MatchService:StartEndgameCollapse(duration)
    if self.Machine:GetState() == STATES.EndgameCollapse then
        return
    end
    self.Machine:Transition(STATES.EndgameCollapse)
    self.CollapseEndTime = os.clock() + duration
    Net.SendToAll("UIMessage", { type = "EndgameCollapse", duration = duration })
end

function MatchService:BroadcastWorldEffect(effectName, duration)
    Net.SendToAll("UIMessage", { type = "WorldEffect", effect = effectName, duration = duration })
end

function MatchService:DistributeResults()
    for _, player in ipairs(Players:GetPlayers()) do
        self.Services.ProgressionService:AwardXP(player, 120)
    end
end

return MatchService
