-- Protect the sorter's recurring tick from uncaught Lua errors.
-- This file is load-order independent: if the main sorter has not loaded yet,
-- a one-time bootstrap installs the guard on the first tick.

local ERROR_LOG_INTERVAL_MS = 60000
local lastErrorAt = nil
local failuresSinceLog = 0

local function timestampMs()
    if getTimestampMs then
        local ok, value = pcall(getTimestampMs)
        if ok and type(value) == "number" then return value end
    end
    return os.clock() * 1000
end

local function reportTickError(err)
    failuresSinceLog = failuresSinceLog + 1
    local now = timestampMs()
    if lastErrorAt and now - lastErrorAt < ERROR_LOG_INTERVAL_MS then return end

    -- Keep the useful reason, but do not emit a stack trace on every tick.
    local message = tostring(err or "unknown error"):match("^[^\r\n]*") or "unknown error"
    local count = failuresSinceLog
    print("[SkillSorter] Scan skipped safely: " .. message
        .. " (" .. tostring(count) .. " failure(s); retrying automatically)")

    lastErrorAt = now
    failuresSinceLog = 0
end

local function installErrorHandler()
    if not SkillSorter or not SkillSorter._tickHandler then return false end
    if SkillSorter._tickHandler == SkillSorter._safeTickHandler then return true end

    local originalTick = SkillSorter._tickHandler
    local function protectedTick(...)
        local ok, err = pcall(originalTick, ...)
        if not ok then reportTickError(err) end
    end

    SkillSorter._safeTickHandler = protectedTick
    SkillSorter._tickHandler = protectedTick
    pcall(function() Events.OnTick.Remove(originalTick) end)
    Events.OnTick.Add(protectedTick)
    return true
end

local function bootstrapErrorHandler()
    if installErrorHandler() then
        pcall(function() Events.OnTick.Remove(bootstrapErrorHandler) end)
    end
end

if not installErrorHandler() then
    Events.OnTick.Add(bootstrapErrorHandler)
end
