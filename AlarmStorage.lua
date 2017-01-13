local AlarmStorage = ZO_CallbackObject:Subclass()
Reminders.AlarmStorage = AlarmStorage

function AlarmStorage:New(saveData)
	local alarmStorage = ZO_CallbackObject.New(self)
	alarmStorage.Alarms = saveData.Alarms or {
		OnLoginAlarms 		= {},
		OnLoginCharAlarms 	= {},
		TimeAlarms 			= {}
	}
	saveData.Alarms = alarmStorage.Alarms
	return alarmStorage
end

function AlarmStorage:AddAlarm(alarm)
	if alarm.Type == Reminders.ON_LOGIN then
		self:AddOnLoginAlarm(alarm)
	elseif alarm.Type == Reminders.ON_LOGIN_CHARACTER then
		self:AddOnLoginCharAlarm(alarm)
	else
		self:AddTimeAlarm(alarm)
	end
end

function AlarmStorage:AddOnLoginAlarm(alarm)
	self.Alarms.OnLoginAlarms[#self.Alarms.OnLoginAlarms + 1] = alarm
end

function AlarmStorage:GetOnLoginAlarms()
	return self.Alarms.OnLoginAlarms
end

function AlarmStorage:AddOnLoginCharAlarm(alarm)
	local charName = alarm.Character
	if not self.Alarms.OnLoginCharAlarms[charName] then
		self.Alarms.OnLoginCharAlarms[charName] = {}
	end
	local alarms = self.Alarms.OnLoginCharAlarms[charName]

	alarms[#alarms + 1] = alarm
end

function AlarmStorage:GetOnLoginCharAlarms(charName)
	return self.Alarms.OnLoginCharAlarms[charName] or {}
end

function AlarmStorage:AddTimeAlarm(alarm)
	local alarms = self.Alarms.TimeAlarms
	local iter = 1

	-- Linear sort, but there will most likely not be enough alarms for this
	-- to make a significant impact. Something to improve when the addon is functional.
	while iter <= #alarms do
		if alarms[iter].DueTime > alarm.DueTime then
			local temp = alarm
			alarm = alarms[iter]
			alarms[iter] = temp
		end
		iter = iter + 1
	end

	alarms[#alarms + 1] = alarm
end

function AlarmStorage:GetNextAlarm()
	return self.Alarms.TimeAlarms[1]
end

function AlarmStorage:RemoveNextAlarm()
	local alarms = self.Alarms.TimeAlarms
	local iter = 1

	while iter < #alarms do
		alarms[iter] = alarms[iter + 1]
		iter = iter + 1
	end

	alarms[iter] = nil
end