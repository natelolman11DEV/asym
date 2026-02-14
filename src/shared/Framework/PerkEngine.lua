local PerkEngine = {}
PerkEngine.__index = PerkEngine

function PerkEngine.new(perkCatalog)
    local self = setmetatable({}, PerkEngine)
    self.Catalog = perkCatalog
    self.Active = {}
    return self
end

function PerkEngine:Equip(player, perkIds)
    self.Active[player] = {}
    for _, id in ipairs(perkIds) do
        local definition = self.Catalog[id]
        if definition then
            table.insert(self.Active[player], {
                id = id,
                hooks = definition.hooks,
                state = {},
            })
        end
    end
end

function PerkEngine:Trigger(player, hookName, context)
    local perks = self.Active[player]
    if not perks then
        return
    end
    for _, perk in ipairs(perks) do
        local hook = perk.hooks and perk.hooks[hookName]
        if hook then
            hook(player, context, perk.state)
        end
    end
end

function PerkEngine:GetActive(player)
    return self.Active[player] or {}
end

return PerkEngine
