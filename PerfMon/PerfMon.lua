PerfMon = PerfMon or {};
local PerfMon = PerfMon;

local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local towstring = towstring
local string_format = string.format

-- Captured at file load so PerfMon's own writes always bypass our hooked wrappers,
-- preventing the elapsed/breakpoint payloads from being double-prefixed.
local TextLogAddEntry = TextLogAddEntry
local TextLogSaveLog = TextLogSaveLog

local path = towstring("")

local recording = false
local logFile = ""
local elapsedThrottle = 1

-- Shared monotonic clock. Advanced once per frame in OnUpdate, read by both the
-- elapsed-sample writer and the wrapped log functions. Starts at zero on each
-- recording session so HTML-side projection has a clean origin.
local cumulativeTime = 0
local cachedPrefix = towstring("[t=0.0000] ")
local cachedPrefixStr = "[t=0.0000] "
local emptyW = towstring("")
local emptyS = ""

-- Originals are stashed when Start() hooks the globals, restored by Stop().
local _origLogLuaMessage = nil
local _origTextLogAddEntry = nil
local _origTextLogAddSingleByteEntry = nil

local function Print(str)
    EA_ChatWindow.Print(towstring(str));
end

function PerfMon.GetCumulativeTime()
    return cumulativeTime
end

-- Wrappers reuse the per-frame cached prefix so high-frequency event bursts
-- inside a single frame allocate one wstring/string for the prefix instead of
-- one per logged entry. The originals are called via local upvalues to avoid
-- the global table dispatch on every call.
local function hookedLogLuaMessage(channel, filterId, text)
    return _origLogLuaMessage(channel, filterId, cachedPrefix .. towstring(text or emptyW))
end

local function hookedTextLogAddEntry(channel, filterId, text)
    return _origTextLogAddEntry(channel, filterId, cachedPrefix .. towstring(text or emptyW))
end

local function hookedTextLogAddSingleByteEntry(channel, filterId, text)
    return _origTextLogAddSingleByteEntry(channel, filterId, cachedPrefixStr .. tostring(text or emptyS))
end

function PerfMon.OnInitialize()
	recording = false;
	elapsedThrottle = 1

	if LibSlash then
		LibSlash.RegisterSlashCmd("perfmon", function(args) PerfMon.SlashCmd(args) end)
		Print(L"<icon=57> PerfMon initialized. Use '/perfmon on' to start monitoring or '/perfmon off' to stop monitoring.");
	end
end

local function setLogFilterEnabled(filterId, enabled)
	DebugWindow.Settings.LogFilters[filterId].enabled = enabled
	ButtonSetPressedFlag("DebugWindowOptionsFilterType" .. filterId .. "Button", enabled)
	LogDisplaySetFilterState("DebugWindowText", "UiLog", filterId, enabled)
	TextLogSetFilterEnabled("UiLog", filterId, enabled)
end


function PerfMon.Start()
	if recording then
		Print("<icon=57> PerfMon is already recording.");
		return
	end

    -- make sure DebugWindow is recording events and function calls
    DebugWindow.Settings.logsOn = true
    DebugWindow.UpdateLog()

	-- enable relevant log filters
	setLogFilterEnabled(5, true) -- function calls
	setLogFilterEnabled(11, true) -- events
	setLogFilterEnabled(3, true) -- errors

	DebugWindow.TextSender()
	DebugWindow.Spy()

    -- get a timestamp for the log file name
	local t = GetComputerTime()
	local d = GetTodaysDate()
	local hours   = math.floor(t / 3600)
	local minutes = math.floor((t % 3600) / 60)
	local seconds = t % 60
	
	local at = string_format(
		"%04d_%02d_%02d_%02d%02d%02d",
		d.todaysYear,
		d.todaysMonth,
		d.todaysDay,
		hours, minutes, seconds
	)

	-- create a log file for elapsed time
	local file = "perfmon_" .. at .. "_elapsed";
	TextLogCreate(file, 999999)
	TextLogSetEnabled(file, true)
	TextLogSetIncrementalSaving(file, true, StringToWString("logs/"..file..".log"))

    -- Reset the monotonic clock and prime the cached prefix so any event that
    -- fires before the first OnUpdate tick still receives a sane stamp.
    cumulativeTime = 0
    cachedPrefixStr = "[t=0.0000] "
    cachedPrefix = towstring(cachedPrefixStr)

    -- Hook the three globals every UI-log payload flows through. The wrappers
    -- prepend the monotonic stamp so HTML 2 can align events sub-second against
    -- the elapsed trace. We must assign through _G explicitly: a bare
    -- `TextLogAddEntry = ...` would rebind the file-level local upvalue, which
    -- would then route PerfMon's own elapsed writes through the hook and
    -- double-prefix them.
    _origLogLuaMessage = _G.LogLuaMessage
    _origTextLogAddEntry = _G.TextLogAddEntry
    _origTextLogAddSingleByteEntry = _G.TextLogAddSingleByteEntry
    _G.LogLuaMessage = hookedLogLuaMessage
    _G.TextLogAddEntry = hookedTextLogAddEntry
    _G.TextLogAddSingleByteEntry = hookedTextLogAddSingleByteEntry

	elapsedThrottle = 0.5
    recording = true
    logFile = file

	Print("<icon=57> started recording to " .. logFile .. ".log");
end


function PerfMon.Stop()
	if not recording then
		Print("<icon=58> PerfMon is not recording.");
		return
	end

    -- Restore globals first so any teardown logging below does not pick up a
    -- stale prefix from the now-dead recording session. Mirror the Start hook
    -- by writing through _G to avoid rebinding the file-level local upvalue.
    if _origLogLuaMessage then _G.LogLuaMessage = _origLogLuaMessage end
    if _origTextLogAddEntry then _G.TextLogAddEntry = _origTextLogAddEntry end
    if _origTextLogAddSingleByteEntry then _G.TextLogAddSingleByteEntry = _origTextLogAddSingleByteEntry end
    _origLogLuaMessage = nil
    _origTextLogAddEntry = nil
    _origTextLogAddSingleByteEntry = nil

    recording = false
    logFile = ""
	elapsedThrottle = 1	

	DebugWindow.Settings.logsOn = false
    DebugWindow.UpdateLog()

	-- disable log filters
	setLogFilterEnabled(5, false) -- function calls
	setLogFilterEnabled(11, false) -- events
	setLogFilterEnabled(3, false) -- errors

	DebugWindow.Settings.LogFilters[11].enabled = false
	ButtonSetPressedFlag( "DebugWindowOptionsFilterType".. 11 .."Button", false )
	LogDisplaySetFilterState( "DebugWindowText", "UiLog", 11, false )
	TextLogSetFilterEnabled( "UiLog", 11, false )

	DebugWindow.Settings.LogFilters[3].enabled = false
	ButtonSetPressedFlag( "DebugWindowOptionsFilterType".. 3 .."Button", false )
	LogDisplaySetFilterState( "DebugWindowText", "UiLog", 3, false )
	TextLogSetFilterEnabled( "UiLog", 3, false )

    DebugWindow.TextSender()
    DebugWindow.SpyStop()

	Print("<icon=58> PerfMon recording has been stopped.");	
end


function PerfMon.Breakpoint()
	if not recording then
		Print("<icon=58> PerfMon is not recording.");
		return
	end

	-- Stamp the breakpoint with the same monotonic prefix so HTML 2 can place it
	-- on the projected sub-second axis instead of a 1-second file timestamp.
	local payload = towstring(string_format("[t=%.4f] BREAKPOINT", cumulativeTime))
	TextLogAddEntry(logFile, 0, payload)
	TextLogSaveLog(logFile, path)
	Print("<icon=57> PerfMon breakpoint inserted.");
end

function PerfMon.SlashCmd(args)
	local command;
	local parameter;
	local separator = string.find(args," ");
	
	if separator then
		command = string.sub(args, 1, separator - 1);
		parameter = string.sub(args, separator + 1, -1);
	else
		command = args;
	end

    -- normalize command
    command = string.lower(command)

    if command == "start" or command == "on" then
        PerfMon.Start();
    elseif command == "stop" or command == "off" then
        PerfMon.Stop();		
    elseif command == "breakpoint" or command == "bp" then
        PerfMon.Breakpoint();
    else
		Print("Unknown PerfMon command.");
	end
end


function PerfMon.OnUpdate(elapsed)
	if not recording then
		return
	end

    -- Advance the monotonic clock first so any event hooked downstream within
    -- this frame stamps with the up-to-date value. The cached prefix is
    -- recomputed exactly once per frame and reused by every wrapper call.
    cumulativeTime = cumulativeTime + elapsed
    cachedPrefixStr = string_format("[t=%.6f] ", cumulativeTime)
    cachedPrefix = towstring(cachedPrefixStr)

	if elapsed <= 0.2 then
        elapsedThrottle = elapsedThrottle - elapsed

        if elapsedThrottle <= 0 then
            local payload = cachedPrefix .. towstring(string_format("%.6f", elapsed))
            TextLogAddEntry(logFile, 0, payload)
			TextLogSaveLog(logFile, path)
			elapsedThrottle = 1
		end

	else
        local payload = cachedPrefix .. towstring(string_format("%.6f", elapsed))
        TextLogAddEntry(logFile, 0, payload)
		TextLogSaveLog(logFile, path)
	end
end
