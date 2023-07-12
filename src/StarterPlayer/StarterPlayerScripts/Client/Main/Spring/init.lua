local RFirst = game:GetService("ReplicatedFirst")
local _Spring = require(script.MoreSpring)
local _Run = require(RFirst.Common.RSWrapper)

local SWrapper = {}

SWrapper.new = function(value, speed, damping, multi: boolean)
	local CurrentSpring = multi and _Spring:MultiAxisSpring(value, speed, damping) or _Spring:Spring(value, speed, damping)
	local SpecialID = _Run.NewID()
	local SpringConfig = {
		_spring = CurrentSpring
	}
	function SpringConfig:Destroy()
		_Run.Remove(SpecialID)
		CurrentSpring = nil
		SpecialID = nil
	end
	_Run.Add(SpecialID, function(dt)
		CurrentSpring:TimeSkip(dt)
	end)
	return SpringConfig
end

return SWrapper
