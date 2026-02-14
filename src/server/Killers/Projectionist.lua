local BaseKiller = require(script.Parent.BaseKiller)

local Projectionist = {}
Projectionist.__index = Projectionist
setmetatable(Projectionist, BaseKiller)

function Projectionist.new(config)
    config.Name = "Projectionist"
    local self = BaseKiller.new(config)
    self.Traps = {}
    return setmetatable(self, Projectionist)
end

function Projectionist:Power(context)
    if not self:CanUse("ReelTrap") then
        return
    end
    if context and context.PlaceTrap then
        table.insert(self.Traps, context.PlaceTrap)
    elseif context and context.TeleportIndex and self.Traps[context.TeleportIndex] then
        self.Model:PivotTo(self.Traps[context.TeleportIndex])
    end
    self:SetCooldown("ReelTrap", 8)
end

function Projectionist:Ultimate()
    if not self:CanUse("DistortionRealm") then
        return
    end
    self.Services.MatchService:BroadcastWorldEffect("BlackWhiteDistortion", 12)
    self:SetCooldown("DistortionRealm", 65)
end

return Projectionist
