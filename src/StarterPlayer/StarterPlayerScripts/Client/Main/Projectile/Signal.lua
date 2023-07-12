local module = {}

function module.new()
	local config = {}
	config.Connections = {}
	config.OpenID = 1
	
	local function increment_id()
		config.OpenID += 1
	end
	
	local function add_connection(callback, id)
		config.Connections[id] = callback
	end
	
	local function remove_connection(id)
		config.Connections[id] = nil
	end

	function config:Connect(func)
		local NextID = config.OpenID
		increment_id()
		add_connection(func, NextID)
		return {
			Disconnect = function()
				remove_connection(NextID)
			end,
		}
	end

	function config:DisconnectAll()
		config.OpenID = 1
		for i, _ in pairs(config.Connections) do
			table.remove(config.Connections, i)
		end
	end

	function config:Fire(...)
		for _, callback in ipairs(config.Connections) do
			callback(...)
		end
	end
	
	return config
end



return module