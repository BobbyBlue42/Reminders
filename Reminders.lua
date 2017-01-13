Reminders = {}
Reminders.Name = "Reminders"
Reminders.NameColour = ZO_ColorDef:New("3FAFFF")
Reminders.TimeColour = ZO_ColorDef:New("FF3030")
Reminders.Version = 1.0

function Reminders.Initialise(_, addonName)
	if addonName ~= Reminders.Name then return end
	EVENT_MANAGER:UnregisterForEvent(Reminders.Name, EVENT_ADD_ON_LOADED)

	Reminders.SaveData = ZO_SavedVars:NewAccountWide("RemindersSaveData", Reminders.Version)
	Reminders.Alarms = Reminders.AlarmStorage:New(Reminders.SaveData)

	SLASH_COMMANDS["/reminder"] = function(input)
		local name, seconds, message = string.match(input, "(.-) (.-) (.-)$")
		if name and seconds and message and name ~= "" and seconds ~= "" and message ~= "" then
			Reminders.Alarms:AddAlarm(Reminders.CreateAlarm(name, message, false, true, Reminders.TIME_SPAN, seconds))
			Print("Set reminder '%s' for %d seconds from now.", name, seconds)
		else
			Print("Please use the format '/reminder [name] [seconds] [message]'.")
		end
	end

	SLASH_COMMANDS["/timeformats"] = function()
		--d("game time (ms): " .. GetGameTimeMilliseconds())
		d("timestamp: " .. GetTimeStamp())
		--d("date: " .. GetDate())
		--d("time string: " .. GetTimeString())
		--d("formatted time: " .. GetFormattedTime())
		--d("date + formatted time: " .. GetDate() .. GetFormattedTime())
	end
end

function Reminders.PlayerLoaded()
	EVENT_MANAGER:UnregisterForEvent(Reminders.Name, EVENT_PLAYER_ACTIVATED)
	Print("Reminders loaded")
	
	for alarm in pairs(Reminders.Alarms:GetOnLoginAlarms()) do
		Reminders.DisplayNotification(alarm)
	end
	for alarm in pairs(Reminders.Alarms:GetOnLoginCharAlarms()) do
		Reminders.DisplayNotification(alarm)
	end

	EVENT_MANAGER:RegisterForUpdate(Reminders.Name, 1000, Reminders.Update)
end

function Reminders.Update()
	local nextAlarm = Reminders.Alarms:GetNextAlarm()
	if nextAlarm and GetTimeStamp() >= nextAlarm.DueTime then
		Reminders.DisplayNotification(nextAlarm)
		Reminders.Alarms:RemoveNextAlarm()
		-- Check if any other alarms should be displayed as well.
		Reminders.Update()
	end
end

function Reminders.DisplayNotification(alarm)
	Print("%s: %s", alarm.Name, alarm.Message)
	--local timeStamp = "[" .. os.date("%X") .. "]"
	--local timeStamp = "[" .. GetTimeStamp() .. "]"
	--timeStamp = Reminders.TimeColour:Colorize(timeStamp)
	--Print("%s %s: %s", timeStamp, alarm.Name, alarm.Message)
end

function Reminders.SlashCommands()
	SLASH_COMMANDS["/reminder"] = function(input)
		local name, seconds, message = string.match(input, "(.-) (.-) (.-)$")
		if name and seconds and message and name ~= "" and seconds ~= "" and message ~= "" then
			Reminders.Alarms:AddAlarm(Reminders.CreateAlarm(name, message, false, true, Reminders.TIME_SPAN, seconds))
			Print("Set reminder '%s' for %d seconds from now.")
		else
			Print("Please use the format '/reminder [name] [seconds] [message]'.")
		end
	end
end

function Print(message, ...)
	df("%s %s", Reminders.NameColour:Colorize("["..Reminders.Name.."]"), message:format(...))
end

EVENT_MANAGER:RegisterForEvent(Reminders.Name, EVENT_PLAYER_ACTIVATED, Reminders.PlayerLoaded)
EVENT_MANAGER:RegisterForEvent(Reminders.Name, EVENT_ADD_ON_LOADED, Reminders.Initialise)

---------------------------------------- Alarms ----------------------------------------
-- Alarms have the following attributes:											  --
--		- Active (boolean)															  --
--		- Name (string)																  --
--		- Message (string)															  --
--		- ShowOnLogin (boolean) (whether to show a notification if the alarm occurred --
--			while user was offline)													  --
--		- IgnoreCombat (boolean) (whether to show a notification even while the user  --
--			is in combat)															  --
--		- Type (SET_TIME, TIME_SPAN, ON_LOGIN, ON_LOGIN_CHARACTER)					  --
--		- DueTime (number) -> only if Type == SET_TIME or Type == TIME_SPAN			  --
--		- UserEnteredTime (number) -> only if Type == TIME_SPAN						  --
--		- Character (string) -> only if Type == ON_LOGIN_CHARACTER					  --
----------------------------------------------------------------------------------------
Reminders.SET_TIME = 1
Reminders.TIME_SPAN = 2
Reminders.ON_LOGIN = 3
Reminders.ON_LOGIN_CHARACTER = 4

function Reminders.CreateAlarm(name, message, showOnLogin, ignoreCombat, type, typeArg)
	local alarm = {
		Name 			= name,
		Message 		= message,
		ShowOnLogin 	= showOnLogin,
		IgnoreCombat 	= ignoreCombat,
		Type 			= type,
	}

	if type == Reminders.SET_TIME or type == Reminders.TIME_SPAN then
		if type == Reminders.SET_TIME then
			alarm.DueTime = typeArg
		else
			alarm.UserEnteredTime = typeArg
			alarm.DueTime = GetTimeStamp() + typeArg
		end
	elseif type == Reminders.ON_LOGIN_CHARACTER then
		alarm.Character = typeArg
	end

	return alarm
end