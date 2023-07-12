local RS = game["Run Service"]
local RSWrapper = {}
RSWrapper.Functions = {}

RSWrapper.NewID = function()
	return os.clock()
end

RSWrapper.Add = function(special_id: number | string, func: (dt : number) -> ())
	table.insert(RSWrapper.Functions, {Function = func, id = special_id})
end

RSWrapper.Remove = function(special_id: number | string)
	for index, entry in next, RSWrapper.Functions do
		if entry.id == special_id then
			table.remove(RSWrapper.Functions, index)
		end
	end
end

RSWrapper.Connection = RS.RenderStepped:Connect(function(dt)
	for i, v in RSWrapper.Functions do
		v.Function(dt)
	end
end)

return RSWrapper