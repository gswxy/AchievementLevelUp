print(">>> Loading AchievementLevelUp, https://www.gswxy.com")

-- 配置项
local CHECK_INTERVAL = 60000 -- 可配置项，定时检查间隔，单位为毫秒（默认一分钟）
local MIN_LEVEL = 10
local MAX_LEVEL = 79

-- 基础概率
local baseProbability = 0.152 -- 可配置项，10级时的基础概率调整为15.2%，在玩家在10级到79级之间获得100个成就的情况下，平均可获得大约10次升级奖励
local k = math.log(10) / (MAX_LEVEL - MIN_LEVEL) -- 计算得到的衰减系数

-- 保存玩家的成就数量
local playerAchievementCounts = {}

-- 设定概率函数，根据等级计算概率
local function getUpgradeProbability(level)
    if level < MIN_LEVEL or level > MAX_LEVEL then
        return 0 -- MIN_LEVEL以下或MAX_LEVEL以上不判定
    end
    -- 概率衰减函数，使用指数衰减
    local probability = baseProbability * math.exp(-k * (level - MIN_LEVEL))
    return probability
end

-- 记录玩家奖励情况到日志文件
local function logAchievementReward(playerId, currentLevel, newLevel, probability)
    local logFile = io.open("/root/games/azeroth-server/bin/lua_scripts/AchievementLevelUp/AchievementLevelUp.log", "a")
    if logFile then
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S")
        logFile:write(string.format("[%s] PlayerID: %d, CurrentLevel: %d, NewLevel: %d, Probability: %.2f%%\n", timeStamp, playerId, currentLevel, newLevel, probability * 100))
        logFile:close()
    end
end

-- 检查玩家成就数量变化的函数
local function CheckAchievementChange(eventId, delay, repeats, player)
    if not player or not player:IsInWorld() then
        return
    end

    local playerId = player:GetGUIDLow()
    local currentAchievementCount = player:GetCompletedAchievementsCount()

    if playerAchievementCounts[playerId] == nil then
        playerAchievementCounts[playerId] = currentAchievementCount
    end

    if currentAchievementCount > playerAchievementCounts[playerId] then
        playerAchievementCounts[playerId] = currentAchievementCount
        local currentLevel = player:GetLevel()
        
        if currentLevel < MIN_LEVEL or currentLevel > MAX_LEVEL then
            return
        end

        local probability = getUpgradeProbability(currentLevel)
        local rand = math.random()
        
        if rand < probability then
            local newLevel = currentLevel + 1
            if newLevel > MAX_LEVEL then
                newLevel = MAX_LEVEL
            end
            player:SetLevel(newLevel)
            player:SendBroadcastMessage("恭喜你！检测到您的成就数量增加，经过克罗米在虚空中漫长时间的摇骰子，很幸运您获得了升级奖励，您现在升到" .. newLevel .. "级了！当前升级触发概率：" .. string.format("%.2f", probability * 100) .. "%")
            logAchievementReward(player:GetGUIDLow(), currentLevel, newLevel, probability)
        else
            player:SendBroadcastMessage("检测到您的成就数量增加，经过克罗米在虚空中漫长时间的摇骰子，很可惜没有获得升级奖励，当前升级触发概率：" .. string.format("%.2f", probability * 100) .. "%")
        end
    end
end

-- 玩家登录时触发的函数
local function OnPlayerLogin(event, player)
    playerAchievementCounts[player:GetGUIDLow()] = player:GetCompletedAchievementsCount()
    player:RegisterEvent(CheckAchievementChange, CHECK_INTERVAL, 0)
end

-- 玩家登出时触发的函数
local function OnPlayerLogout(event, player)
    playerAchievementCounts[player:GetGUIDLow()] = nil
    player:RemoveEvents()
end

-- 注册事件
RegisterPlayerEvent(3, OnPlayerLogin) -- 3是玩家登录事件
RegisterPlayerEvent(4, OnPlayerLogout) -- 4是玩家登出事件

print(">>> AchievementLevelUp script loaded")