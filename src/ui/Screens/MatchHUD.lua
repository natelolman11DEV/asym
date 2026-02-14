local MatchHUD = {}

function MatchHUD.Render(gui)
    local tracker = gui:FindFirstChild("ObjectiveTracker") or Instance.new("TextLabel")
    tracker.Name = "ObjectiveTracker"
    tracker.Size = UDim2.fromScale(0.4, 0.08)
    tracker.Position = UDim2.fromScale(0.3, 0.02)
    tracker.Text = "Objectives pending..."
    tracker.Parent = gui

    local heartbeat = gui:FindFirstChild("Heartbeat") or Instance.new("TextLabel")
    heartbeat.Name = "Heartbeat"
    heartbeat.Size = UDim2.fromScale(0.2, 0.06)
    heartbeat.Position = UDim2.fromScale(0.4, 0.9)
    heartbeat.Text = "Heartbeat: Calm"
    heartbeat.Parent = gui

    local collapse = gui:FindFirstChild("CollapseTimer") or Instance.new("TextLabel")
    collapse.Name = "CollapseTimer"
    collapse.Size = UDim2.fromScale(0.2, 0.06)
    collapse.Position = UDim2.fromScale(0.78, 0.02)
    collapse.Text = ""
    collapse.Parent = gui
end

return MatchHUD
