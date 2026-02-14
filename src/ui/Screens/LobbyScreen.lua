local LobbyScreen = {}

function LobbyScreen.Render(gui)
    local label = gui:FindFirstChild("LobbyLabel") or Instance.new("TextLabel")
    label.Name = "LobbyLabel"
    label.Size = UDim2.fromScale(0.3, 0.08)
    label.Position = UDim2.fromScale(0.35, 0.1)
    label.Text = "Lobby / Intermission"
    label.Parent = gui
end

return LobbyScreen
