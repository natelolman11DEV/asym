local BaseKiller = require(script.Parent.BaseKiller)

local MrDeadAir = {}
MrDeadAir.__index = MrDeadAir
setmetatable(MrDeadAir, BaseKiller)

function MrDeadAir.new(config)
    config.Name = "MrDeadAir"
    local self = BaseKiller.new(config)
    return setmetatable(self, MrDeadAir)
end

function MrDeadAir:Power(context)
    if not self:CanUse("ChannelSurf") then
        return
    end
    self.Services.KillerService:TeleportKillerToCamera(self.Model, context.CameraNode)
    self:SetCooldown("ChannelSurf", 15)
end

function MrDeadAir:Ultimate()
    if not self:CanUse("SeasonFinale") then
        return
    end
    self.Services.MatchService:StartEndgameCollapse(45)
    self.Services.PlayerStateService:ApplyKillerHaste(self.Model, 1.2, 10)
    self:SetCooldown("SeasonFinale", 60)
end

return MrDeadAir
