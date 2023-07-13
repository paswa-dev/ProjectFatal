local UIS = game:GetService("UserInputService")

type InputData = Enum.KeyCode | Enum.UserInputType
type MappingData = { [InputData]: (InputState: Enum.UserInputState) -> () }

local BindMap = {}
BindMap._map = nil

local function _RunMap(index: InputData, ...)
	local Callback = BindMap._map[index]
	if Callback then
		Callback(...)
	end
end

local function ForPairs(t, callback)
	for index, value in pairs(callback) do
		callback(index, value)
	end
end

local function OnInput(input, gpe)
	if not gpe then
		local CaughtInput = (input.KeyCode == Enum.KeyCode.Unknown) and input.UserInputType or input.KeyCode
		_RunMap(CaughtInput, input.UserInputState)
	end
end

function BindMap.map(NewMap: MappingData) --// Overwrite all data
	BindMap._map = NewMap
end

function BindMap.softMap(NewMap: MappingData) --// Add those which do not exist
	if BindMap._map == nil then
		BindMap._map = NewMap
		return
	end
	ForPairs(NewMap, function(input, callback)
		if BindMap._map[input] == nil then
			BindMap._map[input] = callback
		end
	end)
end

function BindMap.hardMap(NewMap: MappingData) --// Override those which exist already.
	if BindMap._map == nil then
		return
	end
	ForPairs(NewMap, function(input, callback)
		if BindMap._map[input] ~= nil then
			BindMap._map[input] = callback
		end
	end)
end

UIS.InputBegan:Connect(OnInput)
UIS.InputEnded:Connect(OnInput)

return BindMap
