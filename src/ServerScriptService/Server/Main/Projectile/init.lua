local cast = {}
local Signal = require(script:WaitForChild("Signal"))

local function GetPositionAtTime(start_position, velocity, acceleration, time)
	return start_position + ((velocity * time) + (0.5 * (acceleration * math.pow(time, 2))))
end

function cast.Class(override : {[string] : any})
	local config = override or {
		Speed = 100 :: number,
		Gravity = 9.8 :: number,
		Lifetime = 10 :: number
	}
	return setmetatable(config, {__index = cast})
end

function cast.Cast(position: Vector3, direction: Vector3, params: RaycastParams) : RaycastResult
	return workspace:Raycast(position, direction, params)
end

function cast:StepCast(Steps, Position, Direction)
	local OnHit = Signal.new()
	local OnStep = Signal.new()
	
	Steps = math.round(Steps)
	local CastData = {}
	CastData.Position = Position
	CastData.NextPosition = Position + Direction
	CastData.Velocity = self.Speed * Direction
	CastData.Acceleration = Vector3.new(0, -self.Gravity)
	CastData.Steps = self.Lifetime/Steps
	CastData.Stopped = false
	
	CastData.OnHit = OnHit
	CastData.OnStep = OnStep
	function CastData:Update(step)
		local Time = self.Steps * step
		self.Position = self.NextPosition
		self.NextPosition = GetPositionAtTime(Position, self.Velocity, self.Acceleration, Time)
	end
	
	function CastData:Cleanup()
		OnHit:DisconnectAll()
		OnStep:DisconnectAll()
	end
	
	task.delay(nil, function()
		for i=1, Steps do
			CastData:Update(i)
			local Response = self.Cast(CastData.Position, CastData.NextPosition-CastData.Position, nil)
			if Response then OnHit:Fire(Response) break else OnStep:Fire(CastData) end
		end
		CastData.Stopped = true
	end)
	
	return CastData
end

function cast:ActiveCast(Position, Direction)
	return self:StepCast(100, Position, Direction)
end

function cast:SafeActiveCast(StepAmount, Position, Direction)
	local SafeCheck = self:StepCast(StepAmount or 5, Position, Direction)
	local Hit = false
	SafeCheck.OnHit:Connect(function()
		Hit = true
		SafeCheck:Cleanup()
	end)
	repeat task.wait() until SafeCheck.Stopped
	if Hit then
		return self:ActiveCast(Position, Direction)
	end
end

return cast