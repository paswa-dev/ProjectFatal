local Datastore = game:GetService("DataStoreService")
local HTTP = game:GetService("HttpService")
local PersistantData = {}

function PersistantData.Connect(name, scope)
	local data = {}
	data._datastore = Datastore:GetDataStore(name, scope)
	return setmetatable(data, { __index = PersistantData })
end

function PersistantData:Update(index, update_function: (old_data: { any }) -> { any })
	local Data = self:Get(index)
	local NewData = update_function(Data)
	if NewData then
		self:Set(index, NewData)
	end
end

function PersistantData:Get(index)
	local Success, Response = pcall(function()
		local Store = self._datastore :: DataStore
		local Data = Store:GetAsync(index)
		return Data
	end)
	if Success then
		return Response
	else
		return nil
	end
end

function PersistantData:Set(index, value)
	local Success, Response = pcall(function()
		local Store = self._datastore :: DataStore
		local Data = Store:SetAsync(index, value)
		return Data
	end)
	if Success then
		return Response
	else
		error(Response)
	end
end

function PersistantData.Encode(x)
	return HTTP:JSONEncode(x)
end

function PersistantData.Decode(x)
	return HTTP:JSONDecode(x)
end

function PersistantData.Retry(amount, func)
	local Response = nil
	for i = 1, amount do
		Response = func()
		if Response then
			break
		end
	end
	return Response
end

return PersistantData
