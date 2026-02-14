local Workspace = game:GetService("Workspace")

local Hitbox = {}

function Hitbox.QueryBox(cframe, size, overlapParams)
    return Workspace:GetPartBoundsInBox(cframe, size, overlapParams)
end

function Hitbox.GetCharacters(parts)
    local found = {}
    for _, part in ipairs(parts) do
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChildOfClass("Humanoid") and not found[model] then
            found[model] = true
        end
    end
    local list = {}
    for model in pairs(found) do
        table.insert(list, model)
    end
    return list
end

function Hitbox.CreateSnapshot(character)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return nil
    end
    return {
        cframe = root.CFrame,
        at = os.clock(),
    }
end

return Hitbox
