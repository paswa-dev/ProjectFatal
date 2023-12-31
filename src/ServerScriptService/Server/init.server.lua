local Main = script:WaitForChild("Main")
local Server = script:WaitForChild("Server")

_G.get = function(name)
	local file = Main:FindFirstChild(name)
	return file and require(file) or nil
end

do
	local function LazyLoad(module)
		local Now = os.clock()
		local _file = require(module)
		if (os.clock() - Now) > 0.1 then
			print(`{module.Name} | Lazy Loaded`)
		end
		return _file
	end
	for _, ExplicitModule in next, Server:GetChildren() do
		local Required = LazyLoad(ExplicitModule)
		if Required["Init"] then
			Required.Init()
		end
	end
end

_G.get = nil
Server:Destroy()
Main:Destroy()
