local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Framework.Net)
local Hitbox = require(ReplicatedStorage.Shared.Framework.Hitbox)

local CombatService = {}
CombatService.__index = CombatService

function CombatService.new(services)
    local self = setmetatable({}, CombatService)
    self.Services = services
    self.Snapshots = {}
    return self
end

function CombatService:Init()
    game:GetService("RunService").Heartbeat:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                self.Snapshots[player] = Hitbox.CreateSnapshot(player.Character)
            end
        end
    end)

    Net.Get("CombatRequest").OnServerEvent:Connect(function(player, payload)
        if not Net.IsAllowed(player, "CombatRequest") then
            return
        end
        self:HandleCombatRequest(player, payload)
    end)
end

function CombatService:HandleCombatRequest(player, payload)
    local role = self.Services.PlayerStateService.State[player] and self.Services.PlayerStateService.State[player].Role
    if role ~= "Killer" then
        return
    end
    local killer = self.Services.KillerService:GetKillerForPlayer(player)
    if not killer then
        return
    end

    if payload.action == "BasicAttack" and killer:CanUse("BasicAttack") then
        killer:BasicAttack(payload.origin)
    elseif payload.action == "Power" then
        killer:Power(payload.context or {})
    elseif payload.action == "Ultimate" then
        killer:Ultimate(payload.context or {})
    end
end

function CombatService:RequestDamage(sourceModel, targetModel, damageType)
    local player = Players:GetPlayerFromCharacter(targetModel)
    if not player or self.Services.PlayerStateService:IsInvulnerable(player) then
        return
    end

    local state = self.Services.PlayerStateService.State[player]
    if not state then
        return
    end

    if damageType == "Injure" then
        state.HealthState = state.HealthState == "Healthy" and "Injured" or "Downed"
    elseif damageType == "Down" then
        state.HealthState = "Downed"
    elseif damageType == "Execute" then
        state.HealthState = "Eliminated"
    end

    self.Services.PlayerStateService:GrantIFrames(player, 0.35)
    self.Services.PerkEngine:Trigger(player, "OnHitTaken", self.Services)
    Net.SendToAll("Replication", {
        type = "HealthState",
        playerId = player.UserId,
        state = state.HealthState,
    })
end

return CombatService
