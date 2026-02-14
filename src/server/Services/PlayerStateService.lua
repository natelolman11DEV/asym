local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Framework.Net)

local PlayerStateService = {}
PlayerStateService.__index = PlayerStateService

function PlayerStateService.new()
    local self = setmetatable({}, PlayerStateService)
    self.State = {}
    return self
end

function PlayerStateService:Init()
    Players.PlayerAdded:Connect(function(player)
        self.State[player] = {
            Role = "Spectator",
            HealthState = "Healthy",
            Stamina = 100,
            Exhausted = false,
            DetectionScale = 1,
            Carrying = false,
            InvulnerableUntil = 0,
        }
    end)

    Players.PlayerRemoving:Connect(function(player)
        self.State[player] = nil
    end)

    Net.Get("ActionRequest").OnServerEvent:Connect(function(player, payload)
        if not Net.IsAllowed(player, "ActionRequest") then
            return
        end
        self:HandleAction(player, payload)
    end)
end

function PlayerStateService:HandleAction(player, payload)
    local state = self.State[player]
    if not state then
        return
    end
    if payload.action == "Carry" and state.Role == "Killer" then
        state.Carrying = true
    elseif payload.action == "Drop" then
        state.Carrying = false
    elseif payload.action == "SkillCheckEscape" and state.HealthState == "Hooked" then
        if math.random() > 0.55 then
            state.HealthState = "Downed"
        end
    end
end

function PlayerStateService:SetRole(player, role)
    if self.State[player] then
        self.State[player].Role = role
    end
end

function PlayerStateService:ApplyInputState(player, input)
    local state = self.State[player]
    if not state then
        return
    end
    if input.sprint and not state.Exhausted then
        state.Stamina = math.max(0, state.Stamina - 8)
        if state.Stamina <= 0 then
            state.Exhausted = true
        end
    else
        state.Stamina = math.min(100, state.Stamina + 5)
        if state.Stamina > 30 then
            state.Exhausted = false
        end
    end
end

function PlayerStateService:RestoreStamina(player)
    local state = self.State[player]
    if state then
        state.Stamina = 100
        state.Exhausted = false
    end
end

function PlayerStateService:ApplySpeedBoost(player, multiplier, duration)
    self:ApplyTimedTag(player, "SpeedBoost", { multiplier = multiplier }, duration)
end

function PlayerStateService:ApplyKillerHaste(killerModel, multiplier, duration)
    local hum = killerModel and killerModel:FindFirstChildOfClass("Humanoid")
    if not hum then
        return
    end
    local base = hum.WalkSpeed
    hum.WalkSpeed = base * multiplier
    task.delay(duration, function()
        if hum.Parent then
            hum.WalkSpeed = base
        end
    end)
end

function PlayerStateService:ApplyAoESlow(killerModel, radius, slowScale, duration)
    local origin = killerModel and killerModel:FindFirstChild("HumanoidRootPart")
    if not origin then
        return
    end
    for player, _ in pairs(self.State) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if root and hum and (root.Position - origin.Position).Magnitude <= radius then
            local base = hum.WalkSpeed
            hum.WalkSpeed = base * slowScale
            task.delay(duration, function()
                if hum.Parent then
                    hum.WalkSpeed = base
                end
            end)
        end
    end
end

function PlayerStateService:ApplyTimedTag(player, key, value, duration)
    local state = self.State[player]
    if not state then
        return
    end
    state[key] = value
    task.delay(duration, function()
        if self.State[player] then
            self.State[player][key] = nil
        end
    end)
end

function PlayerStateService:ModifyDetection(player, delta)
    if self.State[player] then
        self.State[player].DetectionScale = math.max(0.1, self.State[player].DetectionScale + delta)
    end
end

function PlayerStateService:IsInvulnerable(player)
    local state = self.State[player]
    return state and os.clock() < state.InvulnerableUntil
end

function PlayerStateService:GrantIFrames(player, duration)
    if self.State[player] then
        self.State[player].InvulnerableUntil = os.clock() + duration
    end
end

return PlayerStateService
