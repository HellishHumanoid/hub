-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Load Linoria
local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library      = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- Window
local Window = Library:CreateWindow({
    Title    = "Legend Piece",
    Center   = true,
    AutoShow = true,
})

local Tabs = {
    Farm          = Window:AddTab("Farm"),
    FarmSettings  = Window:AddTab("Farm Settings"),
    Teleport      = Window:AddTab("Teleport"),
    Configuration = Window:AddTab("Configuration"),
}

-- ──────────────────────────────────────────────
-- Farm Tab — Left
-- ──────────────────────────────────────────────

local FarmBox = Tabs.Farm:AddLeftGroupbox("Farm")

local AutoLevelToggle = FarmBox:AddToggle("AutoLevel", {
    Text    = "Auto-Level",
    Default = false,
})

local AutoQuestToggle = FarmBox:AddToggle("AutoQuest", {
    Text    = "Auto-Quest",
    Default = false,
})


local BossBox = Tabs.Farm:AddLeftGroupbox("Auto Boss")

local AutoBossToggle = BossBox:AddToggle("AutoBoss", {
    Text    = "Auto-Boss",
    Default = false,
})

local BossDropdown = BossBox:AddDropdown("BossSelect", {
    Values  = { "Red Haired Emperor", "Guardian of The Seas", "Sea Beast" },
    Default = 1,
    Text    = "Boss",
})

local BossHopBox = Tabs.Farm:AddLeftGroupbox("Auto Boss Hop")

local AutoBossHopToggle = BossHopBox:AddToggle("AutoBossHop", {
    Text    = "Auto-Boss Hop",
    Default = false,
})

local BossHopDropdown = BossHopBox:AddDropdown("BossHopSelect", {
    Values  = { "Red Haired Emperor", "Sea Beast" },
    Default = 1,
    Text    = "Boss",
})

local FarmModeDropdown = FarmBox:AddDropdown("FarmMode", {
    Values = {
        "Lv. 0-25",    "Lv. 25-50",   "Lv. 50-75",   "Lv. 75-100",
        "Lv. 100-150", "Lv. 150-175", "Lv. 175-200", "Lv. 200-225",
        "Lv. 225-250", "Lv. 250-275", "Lv. 275-300", "Lv. 300-350",
        "Lv. 350-400", "Lv. 400-450", "Lv. 450-475", "Lv. 475-500",
        "Lv. 500-550", "Lv. 550-575", "Lv. 575-600", "Lv. 600-650",
        "Lv. 650-700", "Lv. 700-725", "Lv. 725-750", "Lv. 750-800",
        "Lv. 800-850", "Lv. 850-875", "Lv. 875-900", "Lv. 900-950",
        "Lv. 950-1000","Lv. 1000",
    },
    Default = 1,
    Text    = "Farm Mode",
})

-- ──────────────────────────────────────────────
-- Configuration & Teleport Tabs built after UI
-- (see bottom of script)
-- ──────────────────────────────────────────────

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("LegendPiece")

-- ──────────────────────────────────────────────
-- Farm Settings Tab
-- ──────────────────────────────────────────────

local SettingsBox = Tabs.FarmSettings:AddLeftGroupbox("Settings")

local function getWeapons()
    local weapons = {}
    local seen = {}
    local function add(name)
        if not name:find("<") and not seen[name] then
            seen[name] = true
            table.insert(weapons, name)
        end
    end
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then add(tool.Name) end
    end
    local char = LocalPlayer.Character
    if char then
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") then add(obj.Name) end
        end
    end
    if #weapons == 0 then table.insert(weapons, "None") end
    return weapons
end

local WeaponDropdown = SettingsBox:AddDropdown("SelectWeapon", {
    Values  = getWeapons(),
    Default = 1,
    Text    = "Select Weapon",
})

SettingsBox:AddButton({
    Text = "Refresh Weapons",
    Func = function()
        WeaponDropdown:SetValues(getWeapons())
    end,
})

local PositionDropdown = SettingsBox:AddDropdown("SelectPosition", {
    Values  = { "Behind", "Below", "Front", "Above" },
    Default = 1,
    Text    = "Select Position",
})

local DistanceSlider = SettingsBox:AddSlider("FarmDistance", {
    Text     = "Farm Distance",
    Default  = 6,
    Min      = 0,
    Max      = 12,
    Rounding = 2,
})

local SkillBox = Tabs.FarmSettings:AddLeftGroupbox("Auto-Skill")

local AutoSkillToggle = SkillBox:AddToggle("AutoSkill", {
    Text    = "Auto-Skill",
    Default = false,
})

local SkillDropdown = SkillBox:AddDropdown("SelectSkills", {
    Values   = { "Z", "X", "C", "V" },
    Multi    = true,
    Default  = {},
    Text     = "Select Skills",
})

local StatBox = Tabs.FarmSettings:AddLeftGroupbox("Auto-Stat")

local AutoStatToggle = StatBox:AddToggle("AutoStat", {
    Text    = "Auto-Stat",
    Default = false,
})

local StatDropdown = StatBox:AddDropdown("SelectStat", {
    Values  = { "Defense", "Melee", "Sword", "Fruit" },
    Default = 1,
    Text    = "Select Stat",
})

local PointsSlider = StatBox:AddSlider("StatPoints", {
    Text     = "Points",
    Default  = 1,
    Min      = 1,
    Max      = 100,
    Rounding = 0,
})

local HakiBox = Tabs.FarmSettings:AddLeftGroupbox("Auto-Haki")

local AutoHakiToggle = HakiBox:AddToggle("AutoHaki", {
    Text    = "Auto-Haki",
    Default = false,
})

-- ──────────────────────────────────────────────
-- Per-mode config
-- mobName   = mob to track/lock onto
-- spawnName = name sent to spawn remote (falls back to mobName)
-- noQuest   = skip quest tracking, kill until all dead then re-spawn
-- ──────────────────────────────────────────────

local FarmConfig = {
    ["Lv. 0-25"]    = { coords = Vector3.new(-449,  -13,  -730),  folder = "Starter Island",      mobName = "Bandit"         },
    ["Lv. 25-50"]   = { coords = Vector3.new(-325,  130,   -75),  folder = "Starter Island",      mobName = "Boss Bandit"    },
    ["Lv. 50-75"]   = { coords = Vector3.new(-89,     3, -2514),  folder = "Marine Island",       mobName = "Marine"         },
    ["Lv. 75-100"]  = { coords = Vector3.new(-141,   65, -2847),  folder = "Marine Island",       mobName = "Trained Marine" },
    ["Lv. 100-150"] = { coords = Vector3.new(97,     72, -2732),  folder = "Marine Island",       mobName = "Axe Hand"       },
    ["Lv. 150-175"] = { coords = Vector3.new(-2178, -35, -2093),  folder = "Pirate Island",       mobName = "Pirate"         },
    ["Lv. 175-200"] = { coords = Vector3.new(-2177, -35, -2107),  folder = "Pirate Island",       mobName = "Clown"          },
    ["Lv. 200-225"] = { coords = Vector3.new(2004,  -28, -3299),  folder = "Jungle Island",       mobName = "Monkey"         },
    ["Lv. 225-250"] = { coords = Vector3.new(1604,  -32, -3703),  folder = "Jungle Island",       mobName = "Gorilla King"   },
    ["Lv. 250-275"] = { coords = Vector3.new(1230,  -32, -1867),  folder = "Floating Restaurant", mobName = "Chef"           },
    ["Lv. 275-300"] = { coords = Vector3.new(1230,  -32, -1867),  folder = "Floating Restaurant", mobName = "Head Chef"      },
    ["Lv. 300-350"] = { coords = Vector3.new(1230,  -32, -1867),  folder = "Floating Restaurant", mobName = "Golden Armor"   },
    ["Lv. 350-400"] = { coords = Vector3.new(-1101, -38, -4774),  folder = "Shark Park",          mobName = "Fishman"        },
    ["Lv. 400-450"] = { coords = Vector3.new(-1472, -35, -4689),  folder = "Shark Park",          mobName = "Shark Man"      },
    ["Lv. 450-475"] = { coords = Vector3.new(4942,   15, -4427),  folder = "Legend Town",         mobName = "Vagabond"       },
    ["Lv. 475-500"] = { coords = Vector3.new(4934,   15, -4434),  folder = "Legend Town",         mobName = "Strong Marine"  },
    ["Lv. 500-550"] = { coords = Vector3.new(4934,   15, -4434),  folder = "Legend Town",         mobName = "Captain Smoker" },
    ["Lv. 550-575"] = { coords = Vector3.new(-3932,  -8, -4340),  folder = "Snow Island",         mobName = "Snow Bandit"    },
    ["Lv. 575-600"] = { coords = Vector3.new(-3932,  -8, -4340),  folder = "Snow Island",         mobName = "Snowman"        },
    ["Lv. 600-650"] = { coords = Vector3.new(-4282, 108, -4851),  folder = "Snow Island",         mobName = "Icy Samurai"    },
    ["Lv. 650-700"] = { coords = Vector3.new(-4529, 139, -4928),  folder = "Snow Island",         mobName = "Yeti"           },
    ["Lv. 700-725"] = { coords = Vector3.new(-2568, -33, -6385),  folder = "Desert Island",       mobName = "Deserter"       },
    ["Lv. 725-750"] = { coords = Vector3.new(-2568, -33, -6385),  folder = "Desert Island",       mobName = "Strong Deserter"},
    ["Lv. 750-800"] = { coords = Vector3.new(-2283, -32, -7361),  folder = "Desert Island",       mobName = "Spikey"         },
    ["Lv. 800-850"] = { coords = Vector3.new(-2613,  57, -7414),  folder = "Desert Island",       mobName = "Sandy"          },
    ["Lv. 850-875"] = { coords = Vector3.new(-369,  767, -8152),  folder = "Sky Island",          mobName = "Sky Soldier"    },
    ["Lv. 875-900"] = { coords = Vector3.new(113,   932, -8244),  folder = "Sky Island",          mobName = "God's Guards"   },
    ["Lv. 900-950"] = { coords = Vector3.new(-1138,1039, -8887),  folder = "Sky Island",          mobName = "Judgement"      },
    ["Lv. 950-1000"]= { coords = Vector3.new(196,  1414, -9675),  folder = "Sky Island",          mobName = "God"            },
    ["Lv. 1000"]    = { coords = Vector3.new(-6222,  10, -8133),  folder = "Dark Castle",         mobName = "Knight Monkey",  noQuest = true             },
}

-- Maps a player level number to the right FarmConfig key
local function getLevelMode(level)
    if     level <   25 then return "Lv. 0-25"
    elseif level <   50 then return "Lv. 25-50"
    elseif level <   75 then return "Lv. 50-75"
    elseif level <  100 then return "Lv. 75-100"
    elseif level <  150 then return "Lv. 100-150"
    elseif level <  175 then return "Lv. 150-175"
    elseif level <  200 then return "Lv. 175-200"
    elseif level <  225 then return "Lv. 200-225"
    elseif level <  250 then return "Lv. 225-250"
    elseif level <  275 then return "Lv. 250-275"
    elseif level <  300 then return "Lv. 275-300"
    elseif level <  350 then return "Lv. 300-350"
    elseif level <  400 then return "Lv. 350-400"
    elseif level <  450 then return "Lv. 400-450"
    elseif level <  475 then return "Lv. 450-475"
    elseif level <  500 then return "Lv. 475-500"
    elseif level <  550 then return "Lv. 500-550"
    elseif level <  575 then return "Lv. 550-575"
    elseif level <  600 then return "Lv. 575-600"
    elseif level <  650 then return "Lv. 600-650"
    elseif level <  700 then return "Lv. 650-700"
    elseif level <  725 then return "Lv. 700-725"
    elseif level <  750 then return "Lv. 725-750"
    elseif level <  800 then return "Lv. 750-800"
    elseif level <  850 then return "Lv. 800-850"
    elseif level <  875 then return "Lv. 850-875"
    elseif level <  900 then return "Lv. 875-900"
    elseif level <  950 then return "Lv. 900-950"
    elseif level <= 1000 then return "Lv. 950-1000"
    else                      return "Lv. 1000"
    end
end

local function getPlayerLevel()
    local ok, text = pcall(function()
        return LocalPlayer.PlayerGui.HUD.Holder.LevelText.Text
    end)
    if not ok or not text then return 0 end
    -- Text format is "Lv. 157" — extract the number
    local level = tonumber(text:gsub(",", ""):match("%d+"))
    return level or 0
end

-- ──────────────────────────────────────────────
-- Helpers
-- ──────────────────────────────────────────────

local Reliable = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("Warp")
    :WaitForChild("Index")
    :WaitForChild("Event")
    :WaitForChild("Reliable")

local Request = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("Warp")
    :WaitForChild("Index")
    :WaitForChild("Event")
    :WaitForChild("Request")

local function getHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function teleport(x, y, z)
    local hrp = getHRP()
    if hrp then hrp.CFrame = CFrame.new(x, y, z) end
end

local function getWeaponName()
    local val = WeaponDropdown.Value
    if val == "None" or val == nil then return nil end
    return val
end

local function equipWeapon()
    local name = getWeaponName()
    if not name then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") and obj.Name == name then return end
    end
    local tool = LocalPlayer.Backpack:FindFirstChild(name)
    if tool then hum:EquipTool(tool) end
end

local function getConfig()
    if AutoLevelToggle.Value then
        local level = getPlayerLevel()
        if level > 0 then
            local mode = getLevelMode(level)
            return FarmConfig[mode] or FarmConfig[FarmModeDropdown.Value] or FarmConfig["Lv. 0-25"]
        end
        -- Level unreadable, fall back to dropdown selection instead of defaulting to Bandits
        return FarmConfig[FarmModeDropdown.Value] or FarmConfig["Lv. 0-25"]
    end
    return FarmConfig[FarmModeDropdown.Value] or FarmConfig["Lv. 0-25"]
end

local function fireSpawnRemote(cfg)
    cfg = cfg or getConfig()
    local args = { buffer.fromstring("B"), { { cfg.spawnName or cfg.mobName } } }
    Reliable:FireServer(unpack(args))
end

local function fireCancelQuestRemote()
    local args = { buffer.fromstring("C"), { {} } }
    Reliable:FireServer(unpack(args))
end

local function fireM1()
    local name = getWeaponName()
    if not name then return end
    local args = { buffer.fromstring("="), { { name } } }
    Reliable:FireServer(unpack(args))
end

local function getAvailablePoints()
    local ok, text = pcall(function()
        return LocalPlayer.PlayerGui.Menu.Main.CharacterFrame.Others.StatsHeader.PointsLabel.Text
    end)
    if not ok or not text then return 0 end
    return tonumber(text:match(">(%d+)</font>")) or 0
end

local function fireHakiRemote()
    Request:FireServer(buffer.fromstring("\t"), "\001", { { "1", {} } })
end

local function fireStatRemote()
    local stat   = StatDropdown.Value
    local points = PointsSlider.Value
    local args = { buffer.fromstring("@"), { { stat, points } } }
    Reliable:FireServer(unpack(args))
end

local function isQuestActive()
    local ok, frame = pcall(function()
        return LocalPlayer.PlayerGui.QuestUI.Main.QuestFrame
    end)
    if not ok or not frame then return false end
    return frame.Position.X.Scale > 0
end

-- Parses the quest level from the QuestFrame header text
-- e.g. "<font size='25'>QUEST</font> <font size='18' ...>Lv. 150</font>" → 150
local function getQuestLevel()
    local ok, text = pcall(function()
        return LocalPlayer.PlayerGui.QuestUI.Main.QuestFrame.Header.TextLabel.Text
    end)
    if not ok or not text then return nil end
    return tonumber(text:match("Lv%.%s*(%d+)"))
end

-- Returns true if the active quest's level range matches the player's current level range
local function isQuestCompatible()
    local questLevel = getQuestLevel()
    if not questLevel then return true end
    return getLevelMode(questLevel) == getLevelMode(getPlayerLevel())
end

local function getMobs(overrideCfg)
    local cfg = overrideCfg or getConfig()
    local ok, folder = pcall(function()
        return workspace.Holder.Mobs[cfg.folder]
    end)
    if not ok or not folder then return {} end
    local mobs = {}
    for _, mob in ipairs(folder:GetChildren()) do
        if mob.Name == cfg.mobName then
            table.insert(mobs, mob)
        end
    end
    return mobs
end

local function isAlive(mob)
    if not mob or not mob.Parent then return false end
    local hum = mob:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getTargetCFrame(mobHRP)
    local dist   = DistanceSlider.Value
    local pos    = PositionDropdown.Value
    local mobPos = mobHRP.CFrame.Position

    if dist == 0 then
        return CFrame.lookAt(mobPos, mobPos + mobHRP.CFrame.LookVector)
    elseif pos == "Behind" then
        local p = mobPos - mobHRP.CFrame.LookVector * dist
        return CFrame.lookAt(p, mobPos) -- face toward mob
    elseif pos == "Front" then
        local p = mobPos + mobHRP.CFrame.LookVector * dist
        return CFrame.lookAt(p, mobPos) -- face toward mob
    elseif pos == "Below" then
        local p = mobPos - Vector3.new(0, dist, 0)
        return CFrame.new(p) * CFrame.Angles(math.pi / 2, 0, 0) -- face up
    elseif pos == "Above" then
        local p = mobPos + Vector3.new(0, dist, 0)
        return CFrame.new(p) * CFrame.Angles(-math.pi / 2, 0, 0) -- face down
    end
    return mobHRP.CFrame
end

local function isFarming()
    return AutoQuestToggle.Value or AutoLevelToggle.Value or AutoBossToggle.Value or AutoBossHopToggle.Value
end

-- Returns the position of whichever mob/boss we're currently locked on
-- Finds the current target's HRP position (boss takes priority over quest mobs)
-- Defined as a late-binding function so getBoss (defined later) resolves correctly
local getCurrentTargetPos
getCurrentTargetPos = function()
    -- getBoss is defined later in the script but resolved at call time
    local ok, bossResult = pcall(function()
        local boss = getBoss and getBoss()
        if boss then
            local hrp = boss:FindFirstChild("HumanoidRootPart")
            if hrp then return hrp.Position end
        end
        return nil
    end)
    if ok and bossResult then return bossResult end

    local mobs = getMobs()
    for _, mob in ipairs(mobs) do
        if mob and isAlive(mob) then
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            if hrp then return hrp.Position end
        end
    end
    return Vector3.new(0, 0, 0)
end

local function fireSkillZ(pos)
    Request:FireServer(buffer.fromstring("\005"), "\001", { { "1", { "ChargeSkill", "Thousand Slices", vector.create(pos.X, pos.Y, pos.Z) } } })
end

local function fireSkillX(pos)
    Request:FireServer(buffer.fromstring("\005"), "\001", { { "1", { "ChargeSkill", "Strongest Slash", vector.create(pos.X, pos.Y, pos.Z) } } })
end

-- Shared per-frame kill loop used by both quest and no-quest modes
local function runKillLoop(shouldContinue, lockedCfg)
    local pos  = PositionDropdown.Value
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum and (pos == "Below" or pos == "Above") then
        hum.AutoRotate = false
    end

    local velConn = game:GetService("RunService").Heartbeat:Connect(function()
        local hrp = getHRP()
        if hrp then
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    while isFarming() and shouldContinue() do
        local mobs   = getMobs(lockedCfg)
        local target = nil
        for _, mob in ipairs(mobs) do
            if mob and isAlive(mob) then target = mob break end
        end
        local hrp = getHRP()
        if hrp and target then
            local mobHRP = target:FindFirstChild("HumanoidRootPart")
            if mobHRP then hrp.CFrame = getTargetCFrame(mobHRP) end
        end
        task.wait()
    end

    velConn:Disconnect()
    if hum then hum.AutoRotate = true end
end

-- ──────────────────────────────────────────────
-- M1 Loop
-- ──────────────────────────────────────────────

task.spawn(function()
    while true do
        task.wait(0.2)
        if isFarming() then pcall(fireM1) end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoStatToggle.Value and getAvailablePoints() > 0 then
            pcall(fireStatRemote)
        end
    end
end)

local function isDarkBladeEquipped()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") and obj.Name:lower():find("dark") and obj.Name:lower():find("blade") then
            return true
        end
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(1)
        if not AutoSkillToggle.Value then continue end
        if not isDarkBladeEquipped() then continue end
        if not isFarming() then continue end

        local pos = getCurrentTargetPos()
        if pos == Vector3.new(0, 0, 0) then continue end

        local selected = SkillDropdown.Value
        if selected["Z"] then
            pcall(fireSkillZ, pos)
            task.wait(0.3)
        end
        if selected["X"] then
            pcall(fireSkillX, pos)
            task.wait(0.3)
        end
    end
end)

-- ──────────────────────────────────────────────
-- Re-equip on death or manual unequip
-- ──────────────────────────────────────────────

local function setupReequip(char)
    char.ChildRemoved:Connect(function(obj)
        if not isFarming() then return end
        local name = getWeaponName()
        if obj:IsA("Tool") and obj.Name == name then
            task.wait(0.15)
            equipWeapon()
        end
    end)
end

setupReequip(Character)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    setupReequip(char)
    if isFarming() then
        task.wait(1)
        equipWeapon()
    end
    if AutoHakiToggle.Value then
        task.wait(1)
        pcall(fireHakiRemote)
    end
end)

AutoHakiToggle:OnChanged(function()
    if AutoHakiToggle.Value then
        pcall(fireHakiRemote)
    end
end)

WeaponDropdown:OnChanged(function()
    if isFarming() then equipWeapon() end
end)

-- ──────────────────────────────────────────────
-- Auto-Quest Loop
-- ──────────────────────────────────────────────

local preFarmCFrame = nil

local function questLoop()
    local hrp = getHRP()
    if hrp then preFarmCFrame = hrp.CFrame end

    while isFarming() do
        pcall(equipWeapon)
        local cfg = getConfig()
        Library:Notify("Level: " .. tostring(getPlayerLevel()) .. " | Mode: " .. tostring(FarmModeDropdown.Value) .. " | Mob: " .. cfg.mobName)
        teleport(cfg.coords.X, cfg.coords.Y, cfg.coords.Z)
        task.wait(3)

        if cfg.noQuest then
            runKillLoop(function()
                local mobs = getMobs(cfg)
                for _, mob in ipairs(mobs) do
                    if mob and isAlive(mob) then return true end
                end
                teleport(cfg.coords.X, cfg.coords.Y, cfg.coords.Z)
                task.wait(3)
                return true
            end, cfg)
        else
            -- Keep firing the spawn remote until the quest becomes active
            local attempts = 0
            repeat
                pcall(fireSpawnRemote, cfg)
                local ok, frame = pcall(function()
                    return LocalPlayer.PlayerGui.QuestUI.Main.QuestFrame
                end)
                local framePos = ok and frame and tostring(math.floor(frame.Position.X.Scale * 1000) / 1000) or "no frame"
                Library:Notify("Attempt " .. attempts + 1 .. " | mob: " .. cfg.mobName .. " | frame X: " .. framePos)
                task.wait(2)
                attempts += 1
            until isQuestActive() or not isFarming() or attempts >= 10

            if not isFarming() then continue end

            -- If quest is for wrong level range, cancel and restart
            if isQuestActive() and not isQuestCompatible() then
                pcall(fireCancelQuestRemote)
                task.wait(0.5)
                continue
            end

            -- Kill mobs — also cancel mid-kill if level range changes
            runKillLoop(function()
                if isQuestActive() and not isQuestCompatible() then
                    pcall(fireCancelQuestRemote)
                    return false
                end
                return isQuestActive()
            end, cfg)
        end

        task.wait(0.5)
    end
end

local farmingActive = false

local function startFarming()
    if farmingActive then return end
    farmingActive = true
    task.spawn(function()
        questLoop()
        farmingActive = false
    end)
end

local function stopFarming()
    task.wait(0.3)
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local hrp  = getHRP()
    if hrp then
        hrp.Anchored               = false
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        if preFarmCFrame then hrp.CFrame = preFarmCFrame end
    end
    if hum then
        hum.AutoRotate = true
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

AutoQuestToggle:OnChanged(function()
    if AutoQuestToggle.Value then
        startFarming()
    elseif not AutoLevelToggle.Value then
        stopFarming()
    end
end)

AutoLevelToggle:OnChanged(function()
    if AutoLevelToggle.Value then
        startFarming()
    elseif not AutoQuestToggle.Value then
        stopFarming()
    end
end)

-- ──────────────────────────────────────────────
-- Auto-Boss
-- ──────────────────────────────────────────────

local BossConfig = {
    ["Red Haired Emperor"]  = { coords = Vector3.new(-6230,  15,  1149), folder = "Rock Island",      mobName = "Red Haired Emperor"    },
    ["Guardian of The Seas"]= { coords = Vector3.new( 4256,  47, -1802), folder = "Sea Beast Island", mobName = "Guardian of The Seas"  },
    ["Sea Beast"]           = { seaBeast = true },
}

local bossActive = false

local function getOrbCount()
    local ok, val = pcall(function()
        return LocalPlayer.Data.Inventory["Sea Beast's Orb"]:GetAttribute("Amount")
    end)
    return (ok and tonumber(val)) or 0
end

local function getBoss()
    local cfg = BossConfig[BossDropdown.Value]
    if not cfg or cfg.seaBeast then return nil end
    local ok, folder = pcall(function()
        return workspace.Holder.Mobs[cfg.folder]
    end)
    if not ok or not folder then return nil end
    return folder:FindFirstChild(cfg.mobName)
end


local function lockAndKill(getMobFn)
    local pos  = PositionDropdown.Value
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum and (pos == "Below" or pos == "Above") then
        hum.AutoRotate = false
    end

    local velConn = game:GetService("RunService").Heartbeat:Connect(function()
        local h = getHRP()
        if h then
            h.AssemblyLinearVelocity  = Vector3.zero
            h.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    while AutoBossToggle.Value do
        local mob = getMobFn()
        if not mob or not isAlive(mob) then break end
        local mobHRP = mob:FindFirstChild("HumanoidRootPart")
        local h = getHRP()
        if h and mobHRP then h.CFrame = getTargetCFrame(mobHRP) end
        task.wait()
    end

    velConn:Disconnect()
    if hum then hum.AutoRotate = true end
end

local function bossLoop()
    local hrp = getHRP()
    if hrp then preFarmCFrame = hrp.CFrame end

    while AutoBossToggle.Value do
        local cfg = BossConfig[BossDropdown.Value]
        if not cfg then task.wait(1) continue end

        -- ── Sea Beast flow ───────────────────────────
        if cfg.seaBeast then
            local guardianCfg = BossConfig["Guardian of The Seas"]

            -- If Sea Beast is already spawned, kill it first
            local existingBeast = nil
            pcall(function() existingBeast = workspace.Holder.Mobs["Sea Beast Island"]["Sea Beast"] end)
            if existingBeast and isAlive(existingBeast) then
                Library:Notify("Sea Beast already up — killing!")
                lockAndKill(function()
                    local ok, mob = pcall(function() return workspace.Holder.Mobs["Sea Beast Island"]["Sea Beast"] end)
                    return ok and mob or nil
                end)
                task.wait(1)
                continue
            end

            -- Phase 1: keep killing Guardians until orb count increases
            local orbsBefore = getOrbCount()
            Library:Notify("Sea Beast: farming Guardian for orb... (" .. orbsBefore .. " orbs)")
            pcall(equipWeapon)
            teleport(guardianCfg.coords.X, guardianCfg.coords.Y, guardianCfg.coords.Z)
            task.wait(1.5)

            while AutoBossToggle.Value and BossDropdown.Value == "Sea Beast" and getOrbCount() <= orbsBefore do
                lockAndKill(function()
                    if BossDropdown.Value ~= "Sea Beast" then return nil end
                    local ok, folder = pcall(function() return workspace.Holder.Mobs[guardianCfg.folder] end)
                    return ok and folder and folder:FindFirstChild(guardianCfg.mobName)
                end)
                -- Guardian died but orb didn't drop yet — wait for respawn and try again
                if getOrbCount() <= orbsBefore then
                    task.wait(3)
                    teleport(guardianCfg.coords.X, guardianCfg.coords.Y, guardianCfg.coords.Z)
                    task.wait(1)
                end
            end

            if not AutoBossToggle.Value or BossDropdown.Value ~= "Sea Beast" then break end

            -- Phase 2: redeem orb, equip it, spawn Sea Beast
            Library:Notify("Sea Beast: orb obtained! Spawning...")
            teleport(4171, 50, -2035)
            task.wait(2)
            Reliable:FireServer(buffer.fromstring("."), { { "Sea Beast's Orb" } })
            task.wait(1)

            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local orb = LocalPlayer.Backpack:FindFirstChild("Sea Beast's Orb")
                if hum and orb then hum:EquipTool(orb) end
            end
            task.wait(0.5)

            local ok, seaBeast = pcall(function() return workspace.Holder.Mobs["Sea Beast Island"]["Sea Beast"] end)
            if ok and seaBeast then
                Request:FireServer(buffer.fromstring("\026"), "\001", { { "1", { seaBeast } } })
            end
            task.wait(2)

            -- Phase 3: kill Sea Beast
            Library:Notify("Sea Beast: spawned! Killing...")
            lockAndKill(function()
                local ok2, mob = pcall(function() return workspace.Holder.Mobs["Sea Beast Island"]["Sea Beast"] end)
                return ok2 and mob or nil
            end)

            task.wait(1)
            continue
        end

        -- ── Normal boss flow ────────────────────────
        pcall(equipWeapon)
        teleport(cfg.coords.X, cfg.coords.Y, cfg.coords.Z)
        task.wait(1.5)

        lockAndKill(getBoss)

        task.wait(3)
    end
end

AutoBossToggle:OnChanged(function()
    if AutoBossToggle.Value then
        if bossActive then return end
        bossActive = true
        task.spawn(function()
            bossLoop()
            bossActive = false
        end)
    else
        task.wait(0.3)
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
        local hrp = getHRP()
        if hrp then
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            if preFarmCFrame then hrp.CFrame = preFarmCFrame end
        end
    end
end)

-- ──────────────────────────────────────────────
-- Auto-Boss Hop
-- ──────────────────────────────────────────────

local REEXECUTE_CODE = [[
wait(5)
loadstring(game:HttpGet("https://raw.githubusercontent.com/HellishHumanoid/hub/refs/heads/main/lp"))()
]]

local function queueReexecute()
    local fn =
        (syn and syn.queue_on_teleport) or
        (type(queue_on_teleport) == "function" and queue_on_teleport) or
        (fluxus and fluxus.queue_on_teleport) or
        (KRNL_ENV and KRNL_ENV.queue_on_teleport)

    if fn then
        local ok, err = pcall(fn, REEXECUTE_CODE)
        Library:Notify(ok and "Re-execute queued!" or "Queue failed: " .. tostring(err))
    else
        Library:Notify("queue_on_teleport not found on this executor!")
    end
end

local visitedServers = { [game.JobId] = true }

local function serverHop()
    local TeleportService = game:GetService("TeleportService")
    local HttpService     = game:GetService("HttpService")

    local ok, result = pcall(function()
        local cursor = nil
        -- Page through servers until we find an unvisited one
        repeat
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId ..
                        "/servers/Public?sortOrder=Asc&limit=100" ..
                        (cursor and ("&cursor=" .. cursor) or "")
            local data = HttpService:JSONDecode(game:HttpGet(url))

            -- Shuffle the server list so we don't always pick the same first entry
            local servers = data.data or {}
            for i = #servers, 2, -1 do
                local j = math.random(i)
                servers[i], servers[j] = servers[j], servers[i]
            end

            for _, server in ipairs(servers) do
                local hasRoom = server.playing < server.maxPlayers
                if hasRoom and not visitedServers[server.id] then
                    visitedServers[server.id] = true
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return true
                end
            end

            cursor = data.nextPageCursor
        until not cursor

        -- All known servers visited, clear history (except current) and retry next call
        visitedServers = { [game.JobId] = true }
        return false
    end)

    if not ok or not result then
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
end

local function waitForGameLoad()
    -- Wait until the mobs folder exists and character is ready
    while not pcall(function() return workspace.Holder.Mobs end) do
        task.wait(1)
    end
    task.wait(2) -- small extra buffer
end

local bossHopActive = false

local function hopKillAndHop(getMobFn, name)
    local mob = getMobFn()
    if not mob or not isAlive(mob) then
        Library:Notify(name .. " not found — hopping...")
        queueReexecute()
        task.wait(0.5)
        serverHop()
        task.wait(15)
        return
    end

    Library:Notify(name .. " found! Killing...")

    local pos = PositionDropdown.Value
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum and (pos == "Below" or pos == "Above") then hum.AutoRotate = false end

    local velConn = game:GetService("RunService").Heartbeat:Connect(function()
        local h = getHRP()
        if h then
            h.AssemblyLinearVelocity  = Vector3.zero
            h.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    while AutoBossHopToggle.Value do
        local target = getMobFn()
        if not target or not isAlive(target) then break end
        local mobHRP = target:FindFirstChild("HumanoidRootPart")
        local h = getHRP()
        if h and mobHRP then h.CFrame = getTargetCFrame(mobHRP) end
        task.wait()
    end

    velConn:Disconnect()
    if hum then hum.AutoRotate = true end
    if not AutoBossHopToggle.Value then return end

    Library:Notify(name .. " killed! Hopping...")
    task.wait(1)
    queueReexecute()
    task.wait(0.5)
    serverHop()
    task.wait(15)
end

local function bossHopLoop()
    waitForGameLoad()

    while AutoBossHopToggle.Value do
        pcall(equipWeapon)
        local selection = BossHopDropdown.Value

        if selection == "Red Haired Emperor" then
            local cfg = BossConfig["Red Haired Emperor"]
            teleport(cfg.coords.X, cfg.coords.Y, cfg.coords.Z)
            task.wait(3)
            hopKillAndHop(function()
                local ok, folder = pcall(function() return workspace.Holder.Mobs[cfg.folder] end)
                return ok and folder and folder:FindFirstChild(cfg.mobName)
            end, "Red Haired Emperor")

        elseif selection == "Sea Beast" then
            local guardianCoords = BossConfig["Guardian of The Seas"].coords
            teleport(guardianCoords.X, guardianCoords.Y, guardianCoords.Z)
            task.wait(3)
            hopKillAndHop(function()
                local ok, mob = pcall(function() return workspace.Holder.Mobs["Sea Beast Island"]["Sea Beast"] end)
                return ok and mob or nil
            end, "Sea Beast")
        end
    end
end

AutoBossHopToggle:OnChanged(function()
    if AutoBossHopToggle.Value then
        if bossHopActive then return end
        bossHopActive = true
        task.spawn(function()
            bossHopLoop()
            bossHopActive = false
        end)
    else
        task.wait(0.3)
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
        local hrp = getHRP()
        if hrp then
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            if preFarmCFrame then hrp.CFrame = preFarmCFrame end
        end
    end
end)

-- ──────────────────────────────────────────────
-- Auto-Level — cancel quest when level range changes
-- ──────────────────────────────────────────────

task.spawn(function()
    local lastMode = nil
    while true do
        task.wait(2)
        if not AutoLevelToggle.Value then
            lastMode = nil
            continue
        end
        local currentMode = getLevelMode(getPlayerLevel())
        if lastMode and currentMode ~= lastMode then
            pcall(fireCancelQuestRemote)
        end
        lastMode = currentMode
    end
end)

-- ──────────────────────────────────────────────
-- Teleport Tab
-- ──────────────────────────────────────────────

local IslandCoords = {
    ["Starter Island"]      = Vector3.new(-533,   42,  -241),
    ["Lonely Island"]       = Vector3.new(  27,  -15, -1363),
    ["Mysterious Tower"]    = Vector3.new( 863,  258,  -783),
    ["Floating Restaurant"] = Vector3.new(1264,   -2, -1907),
    ["Sea Beast Island"]    = Vector3.new(4167,   49, -1968),
    ["Legend Town"]         = Vector3.new(4707,   17, -4410),
    ["Jungle Island"]       = Vector3.new(2007,  -28, -3293),
    ["Marine Island"]       = Vector3.new(  28,  -33, -2418),
    ["Pirate Island"]       = Vector3.new(-2199, -37, -2084),
    ["Rock Island"]         = Vector3.new(-6119,  13,  1117),
    ["Snow Island"]         = Vector3.new(-3991, -13, -4352),
    ["Desert Island"]       = Vector3.new(-2520, -32, -6287),
    ["Sky Island"]          = Vector3.new( -440, 792, -8363),
    ["Dark Castle"]         = Vector3.new(-6209,   1, -8061),
}

local TeleportBox = Tabs.Teleport:AddLeftGroupbox("Teleport")

local IslandDropdown = TeleportBox:AddDropdown("SelectIsland", {
    Values = {
        "Starter Island", "Lonely Island",    "Mysterious Tower",    "Floating Restaurant",
        "Sea Beast Island", "Legend Town",    "Jungle Island",       "Marine Island",
        "Pirate Island",  "Rock Island",      "Snow Island",         "Desert Island",
        "Sky Island",     "Dark Castle",
    },
    Default = 1,
    Text    = "Select Island",
})

TeleportBox:AddButton({
    Text = "Teleport to Island",
    Func = function()
        local coords = IslandCoords[IslandDropdown.Value]
        if coords then
            teleport(coords.X, coords.Y, coords.Z)
        end
    end,
})

-- ──────────────────────────────────────────────
-- Configuration Tab
-- ──────────────────────────────────────────────

SaveManager:BuildConfigSection(Tabs.Configuration)

-- ──────────────────────────────────────────────
-- Init
-- ──────────────────────────────────────────────

ThemeManager:ApplyTheme("Dark Blue")
SaveManager:LoadAutoloadConfig()
