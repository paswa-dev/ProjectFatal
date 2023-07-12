local clamp = math.clamp
local Rand = Random.new()

local module = {}

function module.Clamp2(current: Vector2, min: Vector2, max: Vector2) : Vector2
	return Vector2.new(clamp(current.X, min.X, max.X), clamp(current.Y, min.Y, max.Y))
end

function module.Clamp3(current: Vector3, min: Vector3, max: Vector3) : Vector3
	return Vector3.new(clamp(current.X, min.X, max.X), clamp(current.Y, min.Y, max.Y), clamp(current.Z, min.Z, max.Z))
end

function module.UnpackVector(vector, order, negateorder)
	order = order or "XYZ"
	negateorder = negateorder or "___"
	local Vec = {}
	for i=1, rawlen(order) do
		local vectorIndex = string.sub(order, i, i)
		local negationIndex = string.sub(negateorder, i, i)
		local vectorValue = vector[vectorIndex]
		if negationIndex == "_" then
			Vec[i] = vectorValue
		else
			Vec[i] = -vectorValue
		end
	end
	return table.unpack(Vec)
end

function module.Rand(min, max, random)
	return random and Rand:NextNumber(min, max) or math.random(min, max)
end

return module
