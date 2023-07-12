local lerpInformation = {}
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SampledTime = task.wait()

--[[
`value_signal` is a object that must have a writable and readable `value_signal["Value"]`
This value will be updated, make sure to keep track of it and update your main code via that value.
! value_signal can be a table with ["Value"] !
@API
.any(old: any, new: any, t: number, value_signal: any)
.string(old: string, new: string, t: number, value_signal: any)
]]

local function AccurateWaitV2(t)
	local l = 0 do
		repeat l = l + RS.Heartbeat:Wait() until l >= t
	end
end

local function extend_string(str, add_length)
	if add_length <= 0 then return str end
	for i=1, add_length do
		str = str .. " "
	end
	return str
end

local TypeToObject = {
	["UDim2"] = {"Frame", "Position"},
	["UDim"] = {"UICorner", "CornerRadius"},
	["Vector3"] = {"Vector3Value", "Value"},
	["Vector2"] = {"Frame", "AnchorPoint"},
	["CFrame"] = {"CFrameValue", "Value"},
	["number"] = {"IntValue", "Value"},
	["Color3"] = {"Color3Value", "Value"},
}

function lerpInformation.any(old, new, t, value_signal: any)
	if typeof(old) ~= typeof(new) then return end
	local info = TweenInfo.new(t, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
	local Obj = TypeToObject[typeof(old)]
	local NonComputedObject = Instance.new(Obj[1]) ; NonComputedObject[Obj[2]] = old
	local TSObject = TweenService:Create(NonComputedObject, info, {[Obj[2]]=new})
	TSObject:Play()
	local connection_computed = NonComputedObject:GetPropertyChangedSignal(Obj[2]):Connect(function()
		value_signal.Value = NonComputedObject[Obj[2]]
	end)
	TSObject.Completed:Wait()
	TSObject:Destroy()
	connection_computed:Disconnect()
	NonComputedObject:Destroy()
end

function lerpInformation.string(old_string, new_string, t, value_signal: any)
	if value_signal then
		local current_time = os.clock()
		local c_old = old_string
		old_string = extend_string(old_string, #new_string - #old_string)
		new_string = extend_string(new_string, #c_old - #new_string)
		local old_split, new_split = string.split(old_string, ""), string.split(new_string, "")
		for i, v in old_split do
			task.spawn(function()
				local ByteOld = string.byte(v, 1)
				local AmountToNew = new_string:byte(i) - ByteOld
				local Ration = t/AmountToNew
				local Movement = 1 do
					if AmountToNew < 0 then Movement = -1 end
				end
				for x=Movement, AmountToNew, Movement do
					old_split[i] = string.char(ByteOld + x)
					do
						value_signal.Value = table.concat(old_split, "")
					end
					AccurateWaitV2(Ration)
				end
			end)
		end
	end
end

return lerpInformation
