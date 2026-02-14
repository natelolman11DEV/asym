local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LobbyScreen = require(ReplicatedStorage.UI.Screens.LobbyScreen)
local LoadoutScreen = require(ReplicatedStorage.UI.Screens.LoadoutScreen)
local MatchHUD = require(ReplicatedStorage.UI.Screens.MatchHUD)
local ResultsScreen = require(ReplicatedStorage.UI.Screens.ResultsScreen)

local UIController = {}
UIController.__index = UIController

function UIController.new(controllers)
    return setmetatable({ Controllers = controllers, Gui = nil }, UIController)
end

function UIController:Init()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AsymUI"
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    self.Gui = gui

    MatchHUD.Render(gui)
    LobbyScreen.Render(gui)
    LoadoutScreen.Render(gui, self.Controllers.PerkController.Loadout or { perks = {} })
end

function UIController:UpdateObjectives(objectives)
    local tracker = self.Gui and self.Gui:FindFirstChild("ObjectiveTracker")
    if tracker then
        tracker.Text = string.format("Objectives: %d", #objectives)
    end
end

function UIController:UpdateObjective(objective)
    local tracker = self.Gui and self.Gui:FindFirstChild("ObjectiveTracker")
    if tracker then
        tracker.Text = string.format("%s (%d/%d)", objective.objectiveType, objective.stage, objective.maxStage)
    end
end

function UIController:OnMatchState(state)
    local lobbyLabel = self.Gui and self.Gui:FindFirstChild("LobbyLabel")
    if lobbyLabel then
        lobbyLabel.Visible = state == "Lobby" or state == "Intermission"
    end
    if state == "ResultsScreen" then
        ResultsScreen.Render(self.Gui, 120)
    end
end

function UIController:PushMessage(payload)
    if payload.type == "EndgameCollapse" then
        local collapse = self.Gui and self.Gui:FindFirstChild("CollapseTimer")
        if collapse then
            collapse.Text = string.format("Collapse: %ds", payload.duration)
        end
    end
end

return UIController
