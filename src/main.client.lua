local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Framework.Net)

local playerScripts = script.Parent:WaitForChild("GameClient")
local controllersFolder = playerScripts:WaitForChild("Controllers")

local MovementController = require(controllersFolder:WaitForChild("MovementController"))
local PerkController = require(controllersFolder:WaitForChild("PerkController"))
local UIController = require(controllersFolder:WaitForChild("UIController"))
local ReplicationController = require(controllersFolder:WaitForChild("ReplicationController"))
local InputController = require(controllersFolder:WaitForChild("InputController"))

Net.Init()

local controllers = {}
controllers.MovementController = MovementController.new()
controllers.PerkController = PerkController.new()
controllers.UIController = UIController.new(controllers)
controllers.ReplicationController = ReplicationController.new(controllers)
controllers.InputController = InputController.new(controllers)

controllers.PerkController:Init()
controllers.UIController:Init()
controllers.ReplicationController:Init()
controllers.MovementController:Init()
controllers.InputController:Init()

print("[Asym] Client framework booted")
