local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Net = require(ReplicatedStorage.Shared.Framework.Net)
local PerkEngine = require(ReplicatedStorage.Shared.Framework.PerkEngine)
local Perks = require(ReplicatedStorage.Shared.Data.Perks)

local gameServer = ServerScriptService:WaitForChild("GameServer")
local servicesFolder = gameServer:WaitForChild("Services")

local DataService = require(servicesFolder:WaitForChild("DataService"))
local PlayerStateService = require(servicesFolder:WaitForChild("PlayerStateService"))
local ProgressionService = require(servicesFolder:WaitForChild("ProgressionService"))
local ObjectiveService = require(servicesFolder:WaitForChild("ObjectiveService"))
local KillerService = require(servicesFolder:WaitForChild("KillerService"))
local CombatService = require(servicesFolder:WaitForChild("CombatService"))
local MatchService = require(servicesFolder:WaitForChild("MatchService"))

Net.Init()

local services = {}
services.DataService = DataService.new()
services.PlayerStateService = PlayerStateService.new()
services.PerkEngine = PerkEngine.new(Perks)
services.ProgressionService = ProgressionService.new(services)
services.ObjectiveService = ObjectiveService.new(services)
services.KillerService = KillerService.new(services)
services.CombatService = CombatService.new(services)
services.MatchService = MatchService.new(services)

services.PlayerStateService:Init()
services.ProgressionService:Init()
services.ObjectiveService:Init()
services.CombatService:Init()
services.MatchService:Init()

print("[Asym] Server framework booted")
