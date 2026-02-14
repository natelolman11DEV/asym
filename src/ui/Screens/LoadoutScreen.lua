local LoadoutScreen = {}

function LoadoutScreen.Render(gui, loadout)
    local frame = gui:FindFirstChild("LoadoutFrame") or Instance.new("Frame")
    frame.Name = "LoadoutFrame"
    frame.Size = UDim2.fromScale(0.3, 0.4)
    frame.Position = UDim2.fromScale(0.03, 0.2)
    frame.BackgroundTransparency = 0.2
    frame.Parent = gui

    local label = frame:FindFirstChild("PerkLabel") or Instance.new("TextLabel")
    label.Name = "PerkLabel"
    label.Size = UDim2.fromScale(1, 0.2)
    label.Text = "Perks: " .. table.concat(loadout and loadout.perks or {}, ", ")
    label.Parent = frame
end

return LoadoutScreen
