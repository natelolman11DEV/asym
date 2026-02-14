local Players = game:GetService("Players")

local ProgressionService = {}
ProgressionService.__index = ProgressionService

function ProgressionService.new(services)
    return setmetatable({ Services = services }, ProgressionService)
end

function ProgressionService:Init()
    Players.PlayerAdded:Connect(function(player)
        self.Services.DataService:LoadProfile(player.UserId)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self.Services.DataService:SaveProfile(player.UserId)
    end)
end

function ProgressionService:AwardXP(player, amount)
    local profile = self.Services.DataService.Cache[player.UserId]
    if not profile then
        return
    end
    profile.xp += amount
    local nextLevel = profile.level * 100
    while profile.xp >= nextLevel do
        profile.level += 1
        nextLevel = profile.level * 100
    end
end

return ProgressionService
