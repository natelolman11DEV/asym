local Hitbox = require(game:GetService("ReplicatedStorage").Shared.Framework.Hitbox)

local BaseKiller = {}
BaseKiller.__index = BaseKiller

function BaseKiller.new(config)
    local self = setmetatable({}, BaseKiller)
    self.Name = config.Name
    self.Model = config.Model
    self.Services = config.Services
    self.AudioProfile = config.AudioProfile or {}
    self.AnimationProfile = config.AnimationProfile or {}
    self.PerkPool = config.PerkPool or {}
    self.Cooldowns = {}
    return self
end

function BaseKiller:CanUse(tag)
    local untilTime = self.Cooldowns[tag] or 0
    return os.clock() >= untilTime
end

function BaseKiller:SetCooldown(tag, duration)
    self.Cooldowns[tag] = os.clock() + duration
end

function BaseKiller:BasicAttack(originCFrame)
    local overlap = OverlapParams.new()
    overlap.FilterType = Enum.RaycastFilterType.Exclude
    overlap.FilterDescendantsInstances = { self.Model }
    local parts = Hitbox.QueryBox(originCFrame * CFrame.new(0, 0, -3), Vector3.new(5, 4, 6), overlap)
    local targets = Hitbox.GetCharacters(parts)
    for _, target in ipairs(targets) do
        self.Services.CombatService:RequestDamage(self.Model, target, "Injure")
    end
    self:SetCooldown("BasicAttack", 1)
end

function BaseKiller:Power()
end

function BaseKiller:Ultimate()
end

return BaseKiller
