local Signal = {}
local SignalInterpolation = require(script:WaitForChild("SignalInterpolation"))
local HTTP, RS = game:GetService("HttpService"), game:GetService("RunService")

--[[
@API
.iSignal(x : any) -> boolean
.ApplyToInstance(instance: Instance, signal_properties: {[string]: Signal}, toString: boolean) -> None
.new(value : any) -> Signal

@Signal
.to: (new: any, t: number?) -> Signal,
.AddInstance: (instance : Instance, signal_properties: {any} | {[string]: Signal}, toString: boolean) -> nil,
.UpdateInstances: () -> nil,
.AutoBindInstances: (disable: boolean) -> nil


]]

type Signal = {
	value: any,
	to: (new: any, t: number?) -> Signal,
	AddInstance: (instance : Instance, signal_properties: {any} | {[string]: Signal}, toString: boolean) -> nil,
	UpdateInstances: () -> nil,
	AutoBindInstances: (disable: boolean) -> nil
}

local function FireSignal(v, callback)
	return callback and callback(v()) or v()
end

local function applySignalsToInstance(instance, signal_array, callback)
	for i, v in pairs(signal_array) do
		if Signal.isSignal(v) then 
			instance[i] = FireSignal(v, callback)
		end
	end
end

function Signal.isSignal(x)
	if typeof(x) ~= "table" then return false end
	return x["RenderID"] ~= nil
end

function Signal.ApplyToInstance(instance : Instance, signal_properties : {any}, toString: boolean)
	applySignalsToInstance(instance, signal_properties, toString and tostring or nil)
end

function Signal.new(value)
	local ref_table = {Value = value, Instances = {}, RenderID = HTTP:GenerateGUID(false), isRenderActive=false}
	function ref_table.to(new, t) : Signal
		local isString = SignalInterpolation[typeof(value)]
		if not isString then
			SignalInterpolation.any(ref_table.Value, new, t, ref_table) 
		else 
			isString(ref_table.Value, new, t, ref_table) 
		end
		return ref_table
	end

	function ref_table.AddInstance(instance : Instance, signal_properties, toString: boolean)
		ref_table.Instances[instance] = {array=signal_properties, callback=toString and tostring or nil}
	end

	function ref_table.UpdateInstances()
		for Inst, SigArray in pairs(ref_table.Instances) do
			applySignalsToInstance(Inst, SigArray.array, SigArray.callback)
		end
	end

	function ref_table.AutoBindInstances(disable : boolean)
		if disable then
			if ref_table.isRenderActive then
				RS:UnbindFromRenderStep(ref_table.RenderID)
				ref_table.isRenderActive = false
			end
		else
			if not ref_table.isRenderActive then
				RS:BindToRenderStep(ref_table.RenderID, 100, ref_table.UpdateInstances)
				ref_table.isRenderActive = true
			end
		end
	end

	return setmetatable(ref_table, {
		__call = function(_, value) 
			if not value then return ref_table.Value end
			ref_table.Value = value
		end}
	)
end

return Signal
