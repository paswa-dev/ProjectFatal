local handler = {}

local function SafeGetCFrame(object: PVInstance) : CFrame
	if object:IsA("BasePart") then
		return object.CFrame
	elseif object:IsA("Model") then
		if object.PrimaryPart then
			return object.PrimaryPart.CFrame
		else
			return object:GetPivot()
		end
	end
	return CFrame.new(0,0,0)
end

local function SafeSetCFrame(object: PVInstance, cframe)
	if object:IsA("BasePart") then
		object.CFrame = cframe
	elseif object:IsA("Model") then
		if object.PrimaryPart then
			object.PrimaryPart.CFrame = cframe
		else
			object:PivotTo(cframe)
		end
	end
end

local function GenerateMotors(root_part, model : PVInstance)
	for i, v in model:GetDescendants() do
		if v:IsA("BasePart") and v ~= root_part then
			local newMotor = Instance.new("Motor6D")
			newMotor.Name = v.Name
			newMotor.Part0 = root_part
			newMotor.Part1 = v
			newMotor.C0 = root_part.CFrame:ToObjectSpace(v.CFrame)
			newMotor.C1 = CFrame.new()
			newMotor.Parent = root_part
			v.CanCollide = false
			v.CanQuery = false
			v.CanTouch = false
			v.Anchored = false
		end
	end
end
function handler.wrap(object)
	local config = {
		Object = object
	}
	local MT = {}
	
	function MT:__index(index)
		if index == "CFrame" then
			return SafeGetCFrame(self.Object)
		end
	end
	
	function MT:__newindex(index, value)
		if index == "CFrame" then
			SafeSetCFrame(self.Object, value)
		end
	end
	
	function config:Rig(root_part)
		GenerateMotors(root_part, self.Object)
	end
	
	return setmetatable(config, MT)
end

return handler