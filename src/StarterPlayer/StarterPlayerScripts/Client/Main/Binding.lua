local UIS = game:GetService("UserInputService")

type Input = Enum.UserInputType | Enum.KeyCode

local function ForPairs(t, callback)
	for index, value in pairs(t) do
		callback(index, value)
	end
end

local Binding = {}
Binding._actionMap = {}
Binding._map = {}

local function AddActionToKey(action, key)
	if not Binding._map[key] then
		Binding._map[key] = {}
	end
	table.insert(Binding._map[key], action)
end

local function RemoveActionFromKey(action, key)
	local Ref = Binding._map[key]
	if not Ref then
		return
	end
	table.remove(Binding._map[key], table.find(Ref, action))
end

function Binding.BulkMapAction(ActionMap: { ["string"]: (state: Enum.UserInputState) -> () })
	Binding._actionMap = ActionMap
end

function Binding.Map(action: string, input: Input)
	AddActionToKey(action, input)
end

function Binding.RMap(action: string, input: Input)
	RemoveActionFromKey(action, input)
end

function Binding.BulkRMap(action: string)
	ForPairs(Binding._map, function(input, actions)
		local Index = table.find(actions, action)
		if Index then
			table.remove(Binding._map[input], Index)
		end
	end)
end

function Binding.BulkMap(Map: { [Input]: string })
	ForPairs(Map, function(input, action)
		Binding.Map(action, input)
	end)
end

return Binding
