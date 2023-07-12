local State = {}
local StateMT = {
	__index = State
}

local function Guard(self, name, value)
	if name == nil or value == nil then
		return false
	elseif self.States[name] then
		return self.States[name]
	end
	return true
end

function State.new(object)
	local config = {}
	config.Object = object
	config.States = {}
	return setmetatable(config, StateMT)
end

function State:Destroy()
	for state_name, state_object in pairs(self.States) do
		state_object:Destroy()
	end
end

function State:Signal(name, value)
	local Response = Guard(self, name, value)
	if Response ~= true then
		if not Response then
			error("Signal has thrown fatal error...")
		else
			return Response
		end
	end
	local Object: PVInstance = self.Object
	local CurrentID = 1
	local Connections = {}
	local MT = {}
	local config = {
		Name = name,
		Value = value,
	}
	
	local function OnUpdate(new)
		for _, callback in next, Connections do
			callback(new)
		end
		Object:SetAttribute(name, new)
		rawset(config, "Value", new)
	end
	
	function config:Changed(func: (Value: typeof(value)) -> ()) 
		local Temp_ID = CurrentID
		CurrentID += 1
		Connections[Temp_ID] = func
		return {
			Disconnect = function()
				Connections[Temp_ID] = nil
			end,
		}
	end --// Fix Changed
	
	function config:Destroy()
		Object:SetAttribute(name, nil)
	end
	
	function MT:__call(new_value)
		if new_value == nil then
			return config.Value
		end
		OnUpdate(new_value)
	end
	
	function MT:__newindex(index, new)
		if index == "Value" then
			if config.Value ~= new then
				OnUpdate(new)
			end
		end
	end
	setmetatable(config, MT)
	self.States[name] = config
	return config
end

return State