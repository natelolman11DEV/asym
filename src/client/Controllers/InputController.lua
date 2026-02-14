local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Framework.Net)

local InputController = {}
InputController.__index = InputController

function InputController.new(controllers)
    return setmetatable({ Controllers = controllers, Buffer = {} }, InputController)
end

function InputController:Init()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then
            return
        end
        if input.KeyCode == Enum.KeyCode.LeftShift then
            self.Controllers.MovementController:SetSprint(true)
        elseif input.KeyCode == Enum.KeyCode.C then
            self.Controllers.MovementController:ToggleCrouch()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:BufferCombatAction("BasicAttack")
        elseif input.KeyCode == Enum.KeyCode.Q then
            self:BufferCombatAction("Power")
        elseif input.KeyCode == Enum.KeyCode.R then
            self:BufferCombatAction("Ultimate")
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftShift then
            self.Controllers.MovementController:SetSprint(false)
        end
    end)

    task.spawn(function()
        while true do
            local action = table.remove(self.Buffer, 1)
            if action then
                Net.SendToServer("CombatRequest", {
                    action = action,
                    origin = self.Controllers.MovementController:GetOriginCFrame(),
                    context = {},
                })
            end
            task.wait(0.03)
        end
    end)
end

function InputController:BufferCombatAction(action)
    table.insert(self.Buffer, action)
end

return InputController
