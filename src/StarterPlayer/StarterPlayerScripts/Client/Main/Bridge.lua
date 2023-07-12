local RS = game:GetService("RunService")
local BridgeNet2 = require(script.Parent.Parent.Dependents.BridgeNet2)

local self = {}

function self.new(name)
	return setmetatable({
		_network = BridgeNet2.ReferenceBridge(name),
		_isServer = RS:IsServer()
	}, {__index = self})
end

function self:FireServer(...)
	self._network:Fire({...})
end

function self:FireClient(player, ...)
	self._network:Fire(BridgeNet2.Players({ player }), { ... })
end

function self:FireClients(players, ...)
	self._network:Fire(BridgeNet2.Players(players), { ... })
end

function self:FireAllClients(...)
	self._network:Fire(BridgeNet2.AllPlayers(), { ... })
end

function self:FireClientsExcept(excludePlayers, ...)
	self._network:Fire(BridgeNet2.PlayersExcept(excludePlayers), { ... })
end

function self:Destroy()
	if self._network and self._network.Destroy then
		self._network:Destroy()
	end
end

function self:Connect(callback)
	if self._isServer then
		self._network:Connect(function(player, args)
			callback(player, unpack(args))
		end)
	else
		self._network:Connect(function(args)
			callback(unpack(args))
		end)
	end

	return self
end

return self