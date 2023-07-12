local get = _G.get

local PlayerData = {}
local Datastore = get("Datastore")

local Sessions = Datastore.Connect("ServerData", "Sessions")
local Players = Datastore.Connect("ServerData", "Data")

local function ToSer(plr: Player)
	return "P" .. plr.UserId
end

local function ToDer(s)
	return string.sub(s, 2, string.len(s))
end

local function NewEntry()
	local DataLayout = {
		Kills = 0,
		Rank = 0,
		XP = 0,
		Revives = 0,
		Assist = 0,
		Captures = 0,
		Wins = 0,
		Loss = 0,
	}
	return DataLayout
end

function PlayerData.get(player: Player)
	local PData = {}
	PData._identifier = ToSer(player)
	PData._session = Sessions:Get(PData._identifier) or false
	PData._live = {}
	PData._player = player

	if PData._session == 1 then
		player:Kick("Session Locked. Rejoin")
	else
		Sessions:Set(PData._identifier, 1)
	end

	return setmetatable(PData, { __index = PlayerData })
end

function PlayerData:Save()
	Players:Set(self._identifier, self._live)
end

function PlayerData:Load()
	self._live = Players:Get(self._identifier) or NewEntry()
end

function PlayerData:Get(key)
	return self._live[key]
end

function PlayerData:Set(key, value)
	self._live[key] = value
end

function PlayerData:SoftSet(key, value)
	if self._live[key] == nil then
		self._live[key] = value
	end
end

return PlayerData
