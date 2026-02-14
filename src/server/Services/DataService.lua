local DataStoreService = game:GetService("DataStoreService")

local PROFILE_STORE = DataStoreService:GetDataStore("AsymProfiles_v1")

local DataService = {}
DataService.__index = DataService

function DataService.new()
    return setmetatable({ Cache = {} }, DataService)
end

function DataService:LoadProfile(userId)
    if self.Cache[userId] then
        return self.Cache[userId]
    end

    local key = "p_" .. userId
    local tries = 0
    while tries < 3 do
        tries += 1
        local ok, data = pcall(function()
            return PROFILE_STORE:GetAsync(key)
        end)
        if ok then
            local profile = data or {
                xp = 0,
                level = 1,
                unlockedPerks = { "SecondWind", "QuietMind", "LastHope", "AdrenalSurge" },
                unlockedKillers = { "MrDeadAir" },
                cosmetics = {},
                loadout = { perks = { "SecondWind", "QuietMind", "LastHope" }, item = "Medkit" },
            }
            self.Cache[userId] = profile
            return profile
        end
        task.wait(0.5 * tries)
    end
    return nil
end

function DataService:SaveProfile(userId)
    local profile = self.Cache[userId]
    if not profile then
        return
    end
    local key = "p_" .. userId
    for attempt = 1, 3 do
        local ok = pcall(function()
            PROFILE_STORE:SetAsync(key, profile)
        end)
        if ok then
            return
        end
        task.wait(attempt)
    end
end

return DataService
