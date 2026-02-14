local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local KillerData = require(ReplicatedStorage.Shared.Data.Killers)
local MrDeadAir = require(script.Parent.Parent.Killers.MrDeadAir)
local Wendigo = require(script.Parent.Parent.Killers.Wendigo)
local Projectionist = require(script.Parent.Parent.Killers.Projectionist)

local KillerClassMap = {
    MrDeadAir = MrDeadAir,
    Wendigo = Wendigo,
    Projectionist = Projectionist,
}

local KillerService = {}
KillerService.__index = KillerService

function KillerService.new(services)
    local self = setmetatable({}, KillerService)
    self.Services = services
    self.ActiveKillers = {}
    return self
end

function KillerService:SpawnKiller(player, killerId)
    local template = ServerStorage:FindFirstChild(killerId)
    if not template then
        return nil, "Missing killer model"
    end

    local model = template:Clone()
    model.Parent = workspace
    local class = KillerClassMap[killerId]
    if not class then
        return nil, "Unknown killer class"
    end

    local killer = class.new({
        Model = model,
        Services = self.Services,
        PerkPool = KillerData[killerId] and KillerData[killerId].perkPool or {},
    })
    self.ActiveKillers[player] = killer
    return killer
end

function KillerService:GetKillerForPlayer(player)
    return self.ActiveKillers[player]
end

function KillerService:TeleportKillerToCamera(model, cameraNode)
    if model and cameraNode then
        model:PivotTo(cameraNode)
    end
end

return KillerService
