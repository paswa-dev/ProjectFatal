local Main = script:WaitForChild("Main")
local Client = script:WaitForChild("Client")

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
	for _, ExplicitModule in next, Client:GetChildren() do
		local Required = LazyLoad(ExplicitModule)
		if Required["Init"] then
			Required.Init()
		end
	end
end

_G.get = nil
script.Client:Destroy()
script.Main:Destroy()
