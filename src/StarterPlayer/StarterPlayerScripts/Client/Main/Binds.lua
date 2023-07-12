local UIS = game:GetService("UserInputService")

local module = {
	OnInput = UIS.InputBegan,
	OnRelease = UIS.InputEnded,
	UIS = UIS,
	Types = { Press = 0, Release = 1 },
}

local RegisteredKeys = {}

local function RunAll(t, ...)
	for i, v in next, t do
		v(...)
	end
end

local function register(key)
	RegisteredKeys[key] = {}
end

function module.new()
	local config = {}
	config.Bindings = {}
	config.Types = { Press = 0, Release = 1 }

	function config.Bind(key, func)
		local Index = module.Bind(key, func)
		if not config.Bindings[key] then
			config.Bindings[key] = {}
		end
		table.insert(config.Bindings[key], Index)
		return Index
	end

	function config.UnbindAll()
		for key, KeyContainer in pairs(config.Bindings) do
			for i, index in next, KeyContainer do
				module.Unbind(key, index)
				table.remove(config.Bindings[key], i)
			end
		end
	end

	function config.Unbind(key, index)
		if not config.Bindings[key] then
			return
		elseif not config.Bindings[key][index] then
			return
		end
		config.Bindings[key][index] = nil
	end
	return config
end

function module.Bind(key, func)
	if RegisteredKeys[key] then
		table.insert(RegisteredKeys[key], func)
		return
	end
	if not RegisteredKeys[key] then
		register(key)
		table.insert(RegisteredKeys[key], func)
	end
	return #RegisteredKeys[key]
end

function module.Unbind(key, index_or_function)
	if RegisteredKeys[key] then
		if typeof(index_or_function) == "number" then
			table.remove(RegisteredKeys[key], index_or_function)
			RegisteredKeys[key][index_or_function] = nil
		end
		index_or_function = table.find(RegisteredKeys[key], index_or_function)
		if not index_or_function then
			return
		end
		RegisteredKeys[key][index_or_function] = nil
	end
end

UIS.InputBegan:Connect(function(key, gpe)
	if not gpe then
		if RegisteredKeys[key.KeyCode] then
			RunAll(RegisteredKeys[key.KeyCode], 0)
		elseif RegisteredKeys[key.UserInputType] then
			RunAll(RegisteredKeys[key.UserInputType], 0)
		end
	end
end)

UIS.InputEnded:Connect(function(key, gpe)
	if not gpe then
		if RegisteredKeys[key.KeyCode] then
			RunAll(RegisteredKeys[key.KeyCode], 1)
		elseif RegisteredKeys[key.UserInputType] then
			RunAll(RegisteredKeys[key.UserInputType], 1)
		end
	end
end)

return module
