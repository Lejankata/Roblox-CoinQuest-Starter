--!strict
-- CoinQuest Starter: server-authoritative coin collection for Roblox experiences.
-- Put this Script in ServerScriptService.
-- MIT License. See LICENSE in the repository.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- Adjust these values to match your game.
local CONFIG = {
    DataStoreName = "CoinQuestStarter_v1",
    CoinCount = 12,
    CoinValue = 10,
    RespawnSeconds = 12,
    RingRadius = 34,
    CollectDistance = 14,
    SaveIntervalSeconds = 60,
}

local store = DataStoreService:GetDataStore(CONFIG.DataStoreName)
local sessions: {[Player]: {coins: number, loaded: boolean, dirty: boolean, saving: boolean, persist: boolean}} = {}

local function dataKey(player: Player): string
    return "player_" .. tostring(player.UserId)
end

local function getCoinsStat(player: Player): IntValue?
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return nil end
    local value = leaderstats:FindFirstChild("Coins")
    if value and value:IsA("IntValue") then return value end
    return nil
end

local function savePlayer(player: Player): boolean
    local session = sessions[player]
    if not session or not session.loaded or not session.persist or not session.dirty or session.saving then
        return true
    end
    session.saving = true
    local snapshot = session.coins

    -- UpdateAsync is used for safer writes than SetAsync, but this simple starter
    -- does not provide cross-server session locking for large production games.
    local ok, err = pcall(function()
        store:UpdateAsync(dataKey(player), function(_previous)
            return snapshot
        end)
    end)
    session.saving = false

    if not ok then
        warn("[CoinQuest] Save failed for", player.UserId, err)
        return false
    end
    -- Keep the dirty flag if the balance changed while the save was in flight.
    session.dirty = session.coins ~= snapshot
    return true
end

local function setupPlayer(player: Player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 0
    coins.Parent = leaderstats

    local session = { coins = 0, loaded = false, dirty = false, saving = false, persist = false }
    sessions[player] = session

    local ok, value = pcall(function()
        return store:GetAsync(dataKey(player))
    end)
    if not sessions[player] or not player.Parent then return end

    if ok then
        if typeof(value) == "number" and value >= 0 then
            session.coins = math.floor(value)
        end
    else
        warn("[CoinQuest] Load failed for", player.UserId, value)
        -- Safety choice: permit temporary session play, but never save this balance.
        -- This prevents accidental overwrites when persistent data could not load.
        player:SetAttribute("CoinQuestPersistenceUnavailable", true)
    end

    session.persist = ok
    coins.Value = session.coins
    session.loaded = true
end

local coinFolder = Instance.new("Folder")
coinFolder.Name = "CoinQuestCollectibles"
coinFolder.Parent = workspace

local function findCenter(): Vector3
    local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    if spawn then
        return spawn.Position + Vector3.new(0, 3, 0)
    end
    return Vector3.new(0, 5, 0)
end

local center = findCenter()
local function addCoin(index: number)
    local angle = 2 * math.pi * (index - 1) / CONFIG.CoinCount
    local position = center + Vector3.new(
        math.cos(angle) * CONFIG.RingRadius,
        0,
        math.sin(angle) * CONFIG.RingRadius
    )

    local coin = Instance.new("Part")
    coin.Name = "Coin_" .. tostring(index)
    coin.Shape = Enum.PartType.Ball
    coin.Size = Vector3.new(2.2, 2.2, 2.2)
    coin.Material = Enum.Material.Neon
    coin.Color = Color3.fromRGB(255, 205, 70)
    coin.Anchored = true
    coin.CanCollide = false
    coin.CanTouch = false
    coin.CastShadow = false
    coin.Position = position
    coin.Parent = coinFolder

    local light = Instance.new("PointLight")
    light.Color = coin.Color
    light.Brightness = 1
    light.Range = 9
    light.Parent = coin

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "Collect"
    prompt.ActionText = "Collect +" .. tostring(CONFIG.CoinValue)
    prompt.ObjectText = "Coin"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = coin

    local available = true
    prompt.Triggered:Connect(function(player: Player)
        if not available then return end
        local session = sessions[player]
        if not session or not session.loaded then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root or not root:IsA("BasePart") then return end
        if (root.Position - coin.Position).Magnitude > CONFIG.CollectDistance then return end
        local stat = getCoinsStat(player)
        if not stat then return end

        available = false
        prompt.Enabled = false
        coin.Transparency = 1
        light.Enabled = false

        session.coins += CONFIG.CoinValue
        session.dirty = true
        stat.Value = session.coins

        task.delay(CONFIG.RespawnSeconds, function()
            if not coin.Parent then return end
            available = true
            coin.Transparency = 0
            light.Enabled = true
            prompt.Enabled = true
        end)
    end)
end

for index = 1, CONFIG.CoinCount do
    addCoin(index)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(setupPlayer, player)
end

Players.PlayerRemoving:Connect(function(player)
    -- Save once more if a previous autosave is still running.
    local session = sessions[player]
    if session and session.saving then
        local started = os.clock()
        while session.saving and os.clock() - started < 8 do
            task.wait(0.1)
        end
    end
    savePlayer(player)
    sessions[player] = nil
end)

task.spawn(function()
    while true do
        task.wait(CONFIG.SaveIntervalSeconds)
        for player in pairs(sessions) do
            task.spawn(savePlayer, player)
        end
    end
end)

game:BindToClose(function()
    local pending = 0
    for player in pairs(sessions) do
        pending += 1
        task.spawn(function()
            local s = sessions[player]
            if s and s.saving then
                local started = os.clock()
                while s.saving and os.clock() - started < 8 do
                    task.wait(0.1)
                end
            end
            savePlayer(player)
            pending -= 1
        end)
    end
    local started = os.clock()
    while pending > 0 and os.clock() - started < 25 do
        task.wait(0.1)
    end
end)

print("[CoinQuest] Coins ready. DataStore persistence requires a published experience and Studio API access when testing in Studio.")
