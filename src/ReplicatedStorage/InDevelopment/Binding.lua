local UIS = game:GetService("UserInputService")
local Bind = {}
local MT = {__index = Bind}

function Bind.new(name)
	local data = {}
	data._name = name
	data._substores = {}
	data._connections = {}
	data._bindstore = {}
	data._freeze = false
	
	local function CallFunctions(t, ...)
		for index, callback in pairs(t) do
			if index == data._name then 
				if data._freeze then
					return 
				end
			else
				if data._substores[index]._freeze then
					return
				end
			end
			callback(...)
		end
	end
	
	local function OnInput(i, gpe)
		if not gpe then
			local Action = data._bindstore[i.KeyCode.EnumType] or data._bindstore[i.UserInputType.EnumType]
			if Action then CallFunctions(Action, i.UserInputState) end
		end
	end
	
	local function AddBind(InputObject, i, func)
		if data._bindstore[i.EnumType] == nil then data._bindstore[i.EnumType] = {} end
		data._bindstore[i.EnumType][InputObject._name] = func
	end
	
	local function RemoveBind(InputObject, i)
		if data._bindstore[i.EnumType] then
			data._bindstore[i.EnumType][InputObject._name] = nil
		end
	end
	
	function data:Swap(enum, other_enum)
		local First = data._bindstore[enum.EnumType]
		local Second = data._bindstore[other_enum.EnumType]
		data._bindstore[enum.EnumType] = Second
		data._bindstore[other_enum.EnumType] = First
	end
	
	function data:Bind(key: Enum.KeyCode | Enum.UserInputType, func: (State: Enum.UserInputState) -> (), InputObject)
		InputObject = InputObject or self
		if self._parent then
			self._parent:Bind(key, func, InputObject)
		else
			AddBind(InputObject, key, func)
		end
	end
	
	function data:Unbind(key: Enum.KeyCode | Enum.UserInputType, InputObject)
		InputObject = InputObject or self
		if self._parent then
			self._parent:Unbind(key, InputObject)
		else
			RemoveBind(InputObject, key)
		end
	end
	
	UIS.InputBegan:Connect(OnInput)
	UIS.InputEnded:Connect(OnInput)
	UIS.InputChanged:Connect(OnInput)
	UIS.PointerAction:Connect(OnInput)
	
	return setmetatable(data, {__index = Bind})
end

function Bind:SubCategory(name)
	local data = {}
	data._name = name
	data._freeze = false
	data._parent = self
	setmetatable(data, Bind)
	self._substores[name] = data
	return data
end

function Bind:Freeze()
	self._freeze = true
end

function Bind:Unfreeze()
	self._freeze = false
end

function Bind:FreezeCategory(name)
	local Substore = self._substores[name]
	if Substore then Substore:Freeze() end
end
function Bind:UnfreezeCategory(name)
	local Substore = self._substores[name]
	if Substore then Substore:Unfreeze() end
end

function Bind:GetCategory(name)
	return self._substores[name]
end

return Bind