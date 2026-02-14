local BaseKiller = require(script.Parent.BaseKiller)
local AnimationController = require(game:GetService("ReplicatedStorage").Shared.Framework.AnimationController)

local Wendigo = {}
Wendigo.__index = Wendigo
setmetatable(Wendigo, BaseKiller)

function Wendigo.new(config)
    config.Name = "Wendigo"
    local self = BaseKiller.new(config)
    self.AnimControl = nil
    local humanoid = config.Model and config.Model:FindFirstChildOfClass("Humanoid")
    if humanoid then
        self.AnimControl = AnimationController.new(humanoid)
    end
    return setmetatable(self, Wendigo)
end

function Wendigo:BasicAttack(originCFrame)
    if self.AnimControl then
        self.AnimControl:ProceduralSlash(self.Model:FindFirstChild("HumanoidRootPart"))
    end
    BaseKiller.BasicAttack(self, originCFrame)
end

function Wendigo:Power()
    if not self:CanUse("BoneShriek") then
        return
    end
    self.Services.PlayerStateService:ApplyAoESlow(self.Model, 18, 0.75, 4)
    self:SetCooldown("BoneShriek", 20)
end

function Wendigo:Ultimate()
    if not self:CanUse("FeastMode") then
        return
    end
    self.Services.PlayerStateService:ApplyKillerHaste(self.Model, 1.35, 8)
    self:SetCooldown("FeastMode", 50)
end

return Wendigo
