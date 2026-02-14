local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Net = {}

Net.Definitions = {
    MatchStateChanged = { type = "event" },
    InputState = { type = "event", rateLimit = 0.05 },
    ActionRequest = { type = "event", rateLimit = 0.08 },
    CombatRequest = { type = "event", rateLimit = 0.07 },
    ObjectiveRequest = { type = "event", rateLimit = 0.1 },
    Replication = { type = "event" },
    UIMessage = { type = "event" },
    LoadoutRequest = { type = "function" },
}

local folder
local remotes = {}
local requestLog = {}

local function ensureFolder()
    if folder then
        return folder
    end
    folder = ReplicatedStorage:FindFirstChild("Remotes")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "Remotes"
        folder.Parent = ReplicatedStorage
    end
    return folder
end

function Net.Init()
    local netFolder = ensureFolder()
    for name, config in pairs(Net.Definitions) do
        local remote = netFolder:FindFirstChild(name)
        if not remote then
            remote = config.type == "function" and Instance.new("RemoteFunction") or Instance.new("RemoteEvent")
            remote.Name = name
            remote.Parent = netFolder
        end
        remotes[name] = remote
    end
end

function Net.Get(name)
    if remotes[name] then
        return remotes[name]
    end
    local netFolder = ensureFolder()
    remotes[name] = netFolder:WaitForChild(name)
    return remotes[name]
end

function Net.IsAllowed(player, route)
    local definition = Net.Definitions[route]
    if not definition or not definition.rateLimit then
        return true
    end
    requestLog[player] = requestLog[player] or {}
    local now = os.clock()
    local lastTime = requestLog[player][route] or 0
    if now - lastTime < definition.rateLimit then
        return false
    end
    requestLog[player][route] = now
    return true
end

function Net.SendToAll(route, payload)
    Net.Get(route):FireAllClients(payload)
end

function Net.SendToPlayer(player, route, payload)
    Net.Get(route):FireClient(player, payload)
end

function Net.SendToServer(route, payload)
    if RunService:IsClient() then
        Net.Get(route):FireServer(payload)
    end
end

return Net
