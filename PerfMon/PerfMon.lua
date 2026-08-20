PerfMon = PerfMon or {};
local PerfMon = PerfMon;

-- locals for performance
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local towstring = towstring
local TextLogAddEntry = TextLogAddEntry
local TextLogSaveLog = TextLogSaveLog

local path = towstring("")

local recording = false
local logFile = ""
local elapsedThrottle = 1

local function Print(str)
    EA_ChatWindow.Print(towstring(str));
end

function PerfMon.OnInitialize()
	recording = false;
	elapsedThrottle = 1

	if LibSlash then
		LibSlash.RegisterSlashCmd("perfmon", function(args) PerfMon.SlashCmd(args) end)
		Print(L"<icon=57> PerfMon initialized. Use '/perfmon on' to start monitoring or '/perfmon off' to stop monitoring.");
	end
end


-- (7/7 spikes - 100%) (EA_ChatWindow): EA_ChatWindow.OnTextLogUpdated
-- (7/7 spikes - 100%) (ror_PacketHandling): ror_PacketHandling.OnChatLogUpdated
-- (7/7 spikes - 100%) (Statdoll Remix): Statdoll.Getstats.onUpdate
-- (7/7 spikes - 100%) (RoR_ScenarioExtendedStats): RoR_ScenarioExtendedStats.OnChatLogUpdated
-- (7/7 spikes - 100%) (RoR_MatchMakingRaiting): RoR_MatchMakingRaiting.OnChatLogUpdated
-- (7/7 spikes - 100%) (RoR_MultiSpec): MultiSpec.OnChatLogUpdated
-- (7/7 spikes - 100%) (RoR_RankedLeaderboard): RoR_RankedLeaderboard.OnChatLogUpdated
-- (7/7 spikes - 100%) (RoR_ScenarioSurrenderWindow): RoR_Window_ScenarioSurrender.TextUpdate
-- (7/7 spikes - 100%) ChatManager.OnChatText()
-- (7/7 spikes - 100%) (Queue Queuer): QueueQueuer.OnChat
-- (7/7 spikes - 100%) (Enemy): Enemy.OnChatTextArrived
-- (7/7 spikes - 100%) (EA_ChatWindow): EventDebug_CHAT_TEXT_ARRIVED
-- (7/7 spikes - 100%) "CHAT_TEXT_ARRIVED"
-- (7/7 spikes - 100%) (Enemy): Enemy.KillSpamUI_KillSpamDialog_OnListPopulate
-- (7/7 spikes - 100%) (EA_PlayerStatusWindow): PlayerWindow.UpdateCrown
-- (7/7 spikes - 100%) (BuffHead): BuffHead.OnGroupEffectsUpdated


-- (11/12 spikes - 92%) (EA_ChatWindow): EA_ChatWindow.OnTextLogUpdated
-- (11/12 spikes - 92%) (ror_PacketHandling): ror_PacketHandling.OnChatLogUpdated
-- (11/12 spikes - 92%) (Statdoll Remix): Statdoll.Getstats.onUpdate
-- (11/12 spikes - 92%) (RoR_ScenarioExtendedStats): RoR_ScenarioExtendedStats.OnChatLogUpdated
-- (11/12 spikes - 92%) (RoR_MatchMakingRaiting): RoR_MatchMakingRaiting.OnChatLogUpdated
-- (11/12 spikes - 92%) (RoR_MultiSpec): MultiSpec.OnChatLogUpdated
-- (11/12 spikes - 92%) (RoR_RankedLeaderboard): RoR_RankedLeaderboard.OnChatLogUpdated
-- (11/12 spikes - 92%) (RoR_ScenarioSurrenderWindow): RoR_Window_ScenarioSurrender.TextUpdate
-- (11/12 spikes - 92%) ChatManager.OnChatText()
-- (11/12 spikes - 92%) (Queue Queuer): QueueQueuer.OnChat
-- (11/12 spikes - 92%) (Enemy): Enemy.OnChatTextArrived
-- (11/12 spikes - 92%) (EA_ChatWindow): EventDebug_CHAT_TEXT_ARRIVED
-- (11/12 spikes - 92%) "CHAT_TEXT_ARRIVED"
-- (11/12 spikes - 92%) (BuffHead): BuffHead.OnGroupEffectsUpdated

-- (3/3 spikes - 100%) (EA_ChatWindow): EA_ChatWindow.OnTextLogUpdated( 0.0000, 17.0000 )
-- (3/3 spikes - 100%) (ror_PacketHandling): ror_PacketHandling.OnChatLogUpdated( 0.0000, 17.0000 )
-- (3/3 spikes - 100%) (Statdoll Remix): Statdoll.Getstats.onUpdate( 0.0000, 17.0000 )
-- (3/3 spikes - 100%) (RoR_ScenarioExtendedStats): RoR_ScenarioExtendedStats.OnChatLogUpdated( 0.0000, 17.0000 )
-- (3/3 spikes - 100%) (RoR_MatchMakingRaiting): RoR_MatchMakingRaiting.OnChatLogUpdated( 0.0000, 17.0000 )
-- (3/3 spikes - 100%) (RoR_MultiSpec): MultiSpec.OnChatLogUpdated( 0.0000, 17.0000 )
-- (3/3 spikes - 100%) (RoR_RankedLeaderboard): RoR_RankedLeaderboard.OnChatLogUpdated( 0.0000, 17.0000 )
-- (3/3 spikes - 100%) (RoR_ScenarioSurrenderWindow): RoR_Window_ScenarioSurrender.TextUpdate( 0.0000, 17.0000 )
-- (3/3 spikes - 100%) ChatManager.OnChatText()
-- (3/3 spikes - 100%) (Queue Queuer): QueueQueuer.OnChat()
-- (3/3 spikes - 100%) (Enemy): Enemy.OnChatTextArrived()
-- (3/3 spikes - 100%) (EA_ChatWindow): EventDebug_CHAT_TEXT_ARRIVED()
-- (3/3 spikes - 100%) "CHAT_TEXT_ARRIVED:"
-- (3/3 spikes - 100%) (Enemy): Enemy.KillSpamUI_KillSpamDialog_OnListPopulate( Table [index = -1] )
-- (3/3 spikes - 100%) (EA_PlayerStatusWindow): PlayerWindow.UpdateCrown()
-- (3/3 spikes - 100%) (WSCT): WSCT.PLAYER_EFFECTS_UPDATED( Table [index = -2], false )
-- (3/3 spikes - 100%) (BuffHead): BuffHead.OnGroupEffectsUpdated( Table [index = -2], false )
-- (3/3 spikes - 100%) (Pure): PurePlayer.OnPlayerEffectsUpdated( Table [index = -2], false )
-- (3/3 spikes - 100%) (Enemy): Enemy.Groups_OnCurrentPlayerEffectsUpdated( Table [index = -2], false )
-- (3/3 spikes - 100%) (RVMOD_Targets): RVAPI_Entities.OnPlayerEffectsUpdatedProxy( Table [index = -2], false )
-- (3/3 spikes - 100%) (EA_ChatWindow): EventDebug_PLAYER_EFFECTS_UPDATED( Table [index = -2], false )
-- (3/3 spikes - 100%) (EA_CharacterWindow): CharacterWindow.PlayerEffectsUpdated( Table [index = -2], false )
-- (3/3 spikes - 100%) (EA_ChatWindow): EA_ChatWindow.OnTextLogUpdated( 0.0000, 65.0000 )
-- (3/3 spikes - 100%) (ror_PacketHandling): ror_PacketHandling.OnChatLogUpdated( 0.0000, 65.0000 )
-- (3/3 spikes - 100%) (Statdoll Remix): Statdoll.Getstats.onUpdate( 0.0000, 65.0000 )
-- (3/3 spikes - 100%) (RoR_ScenarioExtendedStats): RoR_ScenarioExtendedStats.OnChatLogUpdated( 0.0000, 65.0000 )
-- (3/3 spikes - 100%) (RoR_MatchMakingRaiting): RoR_MatchMakingRaiting.OnChatLogUpdated( 0.0000, 65.0000 )
-- (3/3 spikes - 100%) (RoR_MultiSpec): MultiSpec.OnChatLogUpdated( 0.0000, 65.0000 )
-- (3/3 spikes - 100%) (RoR_RankedLeaderboard): RoR_RankedLeaderboard.OnChatLogUpdated( 0.0000, 65.0000 )


-- 0,55 sec
-- (2/2 spikes - 100%) (Effigy): Effigy.StateUpdateHandlers.Handler13( 0.0000 )
-- (2/2 spikes - 100%) (EA_ChatWindow): EventDebug_PLAYER_AREA_CHANGED( 0.0000 )
-- (2/2 spikes - 100%) "PLAYER_AREA_CHANGED: 0"
-- (2/2 spikes - 100%) (EA_ObjectiveTrackers): EA_Window_PublicQuestTracker.OnAreaChange( 0.0000 )
-- (2/2 spikes - 100%) "PLAYER_AREA_NAME_CHANGED:"
-- (2/2 spikes - 100%) (EA_ChatWindow): EA_ChatWindow.OnTextLogUpdated( 1.0000, 31.0000 )
-- (2/2 spikes - 100%) (ror_PacketHandling): ror_PacketHandling.OnChatLogUpdated( 1.0000, 31.0000 )
-- (2/2 spikes - 100%) (Statdoll Remix): Statdoll.Getstats.onUpdate( 1.0000, 31.0000 )
-- (2/2 spikes - 100%) (RoR_ScenarioExtendedStats): RoR_ScenarioExtendedStats.OnChatLogUpdated( 1.0000, 31.0000 )
-- (2/2 spikes - 100%) (RoR_MatchMakingRaiting): RoR_MatchMakingRaiting.OnChatLogUpdated( 1.0000, 31.0000 )
-- (2/2 spikes - 100%) (RoR_MultiSpec): MultiSpec.OnChatLogUpdated( 1.0000, 31.0000 )
-- (2/2 spikes - 100%) (RoR_RankedLeaderboard): RoR_RankedLeaderboard.OnChatLogUpdated( 1.0000, 31.0000 )
-- (2/2 spikes - 100%) (RoR_ScenarioSurrenderWindow): RoR_Window_ScenarioSurrender.TextUpdate( 1.0000, 31.0000 )
-- (2/2 spikes - 100%) (EA_ChatWindow): EA_ChatWindow.OnTextLogUpdated( 0.0000, 24.0000 )
-- (2/2 spikes - 100%) (ror_PacketHandling): ror_PacketHandling.OnChatLogUpdated( 0.0000, 24.0000 )
-- (2/2 spikes - 100%) (Statdoll Remix): Statdoll.Getstats.onUpdate( 0.0000, 24.0000 )
-- (2/2 spikes - 100%) (RoR_ScenarioExtendedStats): RoR_ScenarioExtendedStats.OnChatLogUpdated( 0.0000, 24.0000 )
-- (2/2 spikes - 100%) (RoR_MatchMakingRaiting): RoR_MatchMakingRaiting.OnChatLogUpdated( 0.0000, 24.0000 )
-- (2/2 spikes - 100%) (RoR_MultiSpec): MultiSpec.OnChatLogUpdated( 0.0000, 24.0000 )
-- (2/2 spikes - 100%) (RoR_RankedLeaderboard): RoR_RankedLeaderboard.OnChatLogUpdated( 0.0000, 24.0000 )
-- (2/2 spikes - 100%) (RoR_ScenarioSurrenderWindow): RoR_Window_ScenarioSurrender.TextUpdate( 0.0000, 24.0000 )
-- (2/2 spikes - 100%) (EA_OpenPartyWindow): EA_Window_OpenPartyNearby.OnPlayerChapterChanged()
-- (2/2 spikes - 100%) (CMap): CMapWindow.UpdateInfluenceBar()
-- (2/2 spikes - 100%) (EA_ChatWindow): EventDebug_PLAYER_CHAPTER_UPDATED()
-- (2/2 spikes - 100%) "PLAYER_CHAPTER_UPDATED:"
-- (2/2 spikes - 100%) (Enemy): Enemy.Groups_OnCurrentPlayerUpdated()
-- (2/2 spikes - 100%) (EA_PlayerStatusWindow): PlayerWindow.UpdateCrown()
-- (2/2 spikes - 100%) (Effigy): Effigy.StateUpdateHandlers.Handler5()
-- (2/2 spikes - 100%) (EA_ChatWindow): EventDebug_PLAYER_GROUP_LEADER_STATUS_UPDATED()
-- (2/2 spikes - 100%) "PLAYER_GROUP_LEADER_STATUS_UPDATED:"
-- (2/2 spikes - 100%) (EA_ChatWindow): EA_ChatWindow.OnTextLogUpdated( 0.0000, 65.0000 )
-- (2/2 spikes - 100%) (ror_PacketHandling): ror_PacketHandling.OnChatLogUpdated( 0.0000, 65.0000 )
-- (2/2 spikes - 100%) (Statdoll Remix): Statdoll.Getstats.onUpdate( 0.0000, 65.0000 )
-- (2/2 spikes - 100%) (RoR_ScenarioExtendedStats): RoR_ScenarioExtendedStats.OnChatLogUpdated( 0.0000, 65.0000 )
-- (2/2 spikes - 100%) (RoR_MatchMakingRaiting): RoR_MatchMakingRaiting.OnChatLogUpdated( 0.0000, 65.0000 )
-- (2/2 spikes - 100%) (RoR_MultiSpec): MultiSpec.OnChatLogUpdated( 0.0000, 65.0000 )
-- (2/2 spikes - 100%) (RoR_RankedLeaderboard): RoR_RankedLeaderboard.OnChatLogUpdated( 0.0000, 65.0000 )
-- (2/2 spikes - 100%) (RoR_ScenarioSurrenderWindow): RoR_Window_ScenarioSurrender.TextUpdate( 0.0000, 65.0000 )
-- (2/2 spikes - 100%) ChatManager.OnChatText()
-- (2/2 spikes - 100%) (Queue Queuer): QueueQueuer.OnChat()
-- (2/2 spikes - 100%) (Enemy): Enemy.OnChatTextArrived()
-- (2/2 spikes - 100%) (EA_ChatWindow): EventDebug_CHAT_TEXT_ARRIVED()
-- (2/2 spikes - 100%) "CHAT_TEXT_ARRIVED:"


-- (64/73 spikes - 88%) ChatManager.OnChatText()
-- (64/73 spikes - 88%) (Queue Queuer): QueueQueuer.OnChat()
-- (64/73 spikes - 88%) (Enemy): Enemy.OnChatTextArrived()
-- (64/73 spikes - 88%) (EA_ChatWindow): EventDebug_CHAT_TEXT_ARRIVED()
-- (64/73 spikes - 88%) "CHAT_TEXT_ARRIVED:"
-- (62/73 spikes - 85%) (EA_ChatWindow): EA_ChatWindow.OnTextLogUpdated( 0.0000, 65.0000 )
-- (62/73 spikes - 85%) (ror_PacketHandling): ror_PacketHandling.OnChatLogUpdated( 0.0000, 65.0000 )
-- (62/73 spikes - 85%) (Statdoll Remix): Statdoll.Getstats.onUpdate( 0.0000, 65.0000 )
-- (62/73 spikes - 85%) (RoR_ScenarioExtendedStats): RoR_ScenarioExtendedStats.OnChatLogUpdated( 0.0000, 65.0000 )
-- (62/73 spikes - 85%) (RoR_MatchMakingRaiting): RoR_MatchMakingRaiting.OnChatLogUpdated( 0.0000, 65.0000 )
-- (62/73 spikes - 85%) (RoR_MultiSpec): MultiSpec.OnChatLogUpdated( 0.0000, 65.0000 )
-- (62/73 spikes - 85%) (RoR_RankedLeaderboard): RoR_RankedLeaderboard.OnChatLogUpdated( 0.0000, 65.0000 )
-- (62/73 spikes - 85%) (RoR_ScenarioSurrenderWindow): RoR_Window_ScenarioSurrender.TextUpdate( 0.0000, 65.0000 )


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
	
	local at = string.format(
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
    else
		Print("Unknown PerfMon command.");
	end
end


function PerfMon.OnUpdate(elapsed)
	if not recording then
		return
	end

	-- if elapsed is less or equal to 0.2 seconds, throttle logging
	if elapsed <= 0.2 then
        elapsedThrottle = elapsedThrottle - elapsed

        if elapsedThrottle <= 0 then
			TextLogAddEntry(logFile, 0, towstring(elapsed))
			TextLogSaveLog(logFile, path)
			elapsedThrottle = 1
		end

	-- log right away
	else
		TextLogAddEntry(logFile, 0, towstring(elapsed))
		TextLogSaveLog(logFile, path)
	end
end