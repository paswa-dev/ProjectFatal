local clock = {}

function clock.new(callback: (_time: number) -> ())
	local config = {}
	config.Elasped = 0
	config.Paused = false
	config.Thread = coroutine.create(function()
		while true do
			callback(config.Elasped)
			if config.Paused then coroutine.yield() else config.Elasped += task.wait() end
		end
	end)
	return setmetatable(config, {__index = clock})
end

function clock:Start()
	self.Paused = false
	if (coroutine.status(self.Thread) == "suspended") then
		coroutine.resume(self.Thread)
	end
end

function clock:Stop()
	self.Paused = true
end

function clock:Destroy()
	self:Stop()
	coroutine.close(self.Thread)
end

return clock