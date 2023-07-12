local RFirst = game.ReplicatedFirst
local v2 = Vector2.new
local v3 = Vector3.new

local MS = {}
local Spring = require(script.Spring)

function MS:MultiAxisSpring(x : Vector3 | Vector2, speed : Vector3 | Vector2, damping: Vector3 | Vector2)
	local Springs = {}
	local isVector3 = typeof(x) == "Vector3"
	Springs.Value = {X=nil, Y=nil, Z=nil}
	if typeof(x) == "Vector3" then
		Springs.Value.X = MS:Spring(x.X, speed.X, damping.X)
		Springs.Value.Y = MS:Spring(x.Y, speed.Y, damping.Y)
		Springs.Value.Z = MS:Spring(x.Z, speed.Z, damping.Z)
	elseif (typeof(x) == "Vector2") then
		Springs.Value.X = MS:Spring(x.X, speed.X, damping.X)
		Springs.Value.Y = MS:Spring(x.Y, speed.Y, damping.Y)
	end

	function Springs:TimeSkip(dt)
		for i, v in pairs(Springs.Value) do
			if v then
				v:TimeSkip(dt)
			end
		end
	end

	function Springs:Impulse(vector)
		for axis, s in pairs(Springs.Value) do
			if s then
				s:Impulse(vector[axis])
			end
		end
	end

	return setmetatable(Springs, {
		__newindex = function(_, index, value)
			if index == "Target" and value then
				for axis, s in pairs(Springs.Value) do
					if s then
						s.Target = value[axis]
					end
				end
			end
		end,
		__index = function(_, index)
			if index == "Position" then
				if isVector3 then 
					return v3(Springs.Value.X.Position, Springs.Value.Y.Position, Springs.Value.Z.Position)
				elseif not isVector3 then
					return v2(Springs.Value.X.Position, Springs.Value.Y.Position)
				end
			end
		end,
	})
end

function MS:Spring(value, speed, damping)
	local s = Spring.new(value)
	s._speed = speed or 5
	s._damper = damping or 1
	return s
end

return MS