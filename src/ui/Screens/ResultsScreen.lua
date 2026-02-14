local ResultsScreen = {}

function ResultsScreen.Render(gui, xpGained)
    local label = gui:FindFirstChild("ResultsLabel") or Instance.new("TextLabel")
    label.Name = "ResultsLabel"
    label.Size = UDim2.fromScale(0.5, 0.3)
    label.Position = UDim2.fromScale(0.25, 0.35)
    label.Text = string.format("Match Complete\nXP +%d", xpGained or 0)
    label.Parent = gui
end

return ResultsScreen
