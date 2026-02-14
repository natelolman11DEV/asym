local AnimationController = {}
AnimationController.__index = AnimationController

function AnimationController.new(humanoid)
    local self = setmetatable({}, AnimationController)
    self.Humanoid = humanoid
    self.Tracks = {}
    return self
end

function AnimationController:Load(key, animationId)
    local anim = Instance.new("Animation")
    anim.AnimationId = animationId
    self.Tracks[key] = self.Humanoid:LoadAnimation(anim)
    return self.Tracks[key]
end

function AnimationController:Play(key, fadeTime, weight, speed)
    local track = self.Tracks[key]
    if not track then
        return
    end
    track:Play(fadeTime or 0.1, weight or 1, speed or 1)
end

function AnimationController:Stop(key, fadeTime)
    local track = self.Tracks[key]
    if track then
        track:Stop(fadeTime or 0.1)
    end
end

function AnimationController:ProceduralSlash(rootPart)
    if not rootPart then
        return
    end
    local original = rootPart.CFrame
    rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(20), 0)
    task.delay(0.12, function()
        if rootPart.Parent then
            rootPart.CFrame = original
        end
    end)
end

return AnimationController
