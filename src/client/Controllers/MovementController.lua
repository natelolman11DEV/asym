local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Framework.Net)

local MovementController = {}
MovementController.__index = MovementController

function MovementController.new()
    return setmetatable({ Sprinting = false, Crouched = false, PredictedStamina = 100 }, MovementController)
end

function MovementController:Init()
    RunService.RenderStepped:Connect(function(dt)
        self:Tick(dt)
    end)
end

function MovementController:Tick(dt)
    local character = Players.LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    local baseSpeed = self.Crouched and 8 or 14
    if self.Sprinting and self.PredictedStamina > 0 then
        humanoid.WalkSpeed = 20
        self.PredictedStamina = math.max(0, self.PredictedStamina - 30 * dt)
    else
        humanoid.WalkSpeed = baseSpeed
        self.PredictedStamina = math.min(100, self.PredictedStamina + 18 * dt)
    end

    Net.SendToServer("InputState", { sprint = self.Sprinting, crouch = self.Crouched })
end

function MovementController:GetOriginCFrame()
    local character = Players.LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return root and root.CFrame or CFrame.new()
end

function MovementController:SetSprint(state)
    self.Sprinting = state
end

function MovementController:ToggleCrouch()
    self.Crouched = not self.Crouched
end

return MovementController
