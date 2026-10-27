-- Protect the sorter's recurring tick from uncaught Lua errors.
-- This file is load-order independent: if the main sorter has not loaded yet,
-- a one-time bootstrap installs the guard on the first tick.

local FAILURE_WINDOW_MS = 60 * 60 * 1000
local FAILURE_THRESHOLD = 100
local recentFailures = {}
local lastAlertAt = nil

local function timestampMs()
    if getTimestampMs then
        local ok, value = pcall(getTimestampMs)
        if ok and type(value) == "number" then return value end
    end
    return os.clock() * 1000
end

local function reportTickError(err)
    local now = timestampMs()
    recentFailures[#recentFailures + 1] = now

    -- Only the most recent 101 timestamps are needed to detect the threshold.
    if #recentFailures > FAILURE_THRESHOLD + 1 then
        table.remove(recentFailures, 1)
    end

    -- Stay completely silent unless there are more than 100 failures in a
    -- rolling 60-minute window. Even then, emit at most one line per hour.
    if #recentFailures <= FAILURE_THRESHOLD then return end
    if now - recentFailures[1] >= FAILURE_WINDOW_MS then return end
    if lastAlertAt and now - lastAlertAt < FAILURE_WINDOW_MS then return end

    local message = tostring(err or "unknown error"):match("^[^\r\n]*") or "unknown error"
    print("[SkillSorter] Repeated scan failures: " .. message
        .. " (more than 100 failures in 60 minutes; continuing to retry quietly)")
    lastAlertAt = now
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
