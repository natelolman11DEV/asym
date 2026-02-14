local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Framework.Net)

local PerkController = {}
PerkController.__index = PerkController

function PerkController.new()
    return setmetatable({ Loadout = nil }, PerkController)
end

function PerkController:Init()
    self.Loadout = Net.Get("LoadoutRequest"):InvokeServer({ mode = "Get" })
end

function PerkController:SetLoadout(loadout)
    self.Loadout = loadout
    Net.Get("LoadoutRequest"):InvokeServer({ mode = "Set", loadout = loadout })
end

return PerkController
