
local pin = {}
pin.Signal = require(script:WaitForChild("Signals"))

pin.Init = false
pin.DebugRoot = nil

type PinData = {
	Children: {any}
}

type PinInfo = {
	Adornee: Part | Vector3,
	PinData : PinData,
	[any]: any,
}

---- Mapping

---- UI Public Functions
---- Local Functions

local function UpdatePinPosition(pin: PinInfo)
	if typeof(pin.Adornee) == "Vector3" then
		return workspace.CurrentCamera:WorldToScreenPoint(pin.Adornee)
	end
	return workspace.CurrentCamera:WorldToScreenPoint(pin.Adornee["Position"] or pin.Adornee:GetPivot())
end

local function MakePinData(...): PinData
	local data = {
		Children = {}
	}
	for _, v in next, {...} do table.insert(data.Children, v) end
	return data
end

local function MakePinInfo(adornee: Instance | Vector3 | nil, PinData : PinData | nil, misc: {any}) : PinInfo
	local info = {
		Adornee = adornee or Vector3.zero,
		PinData = PinData or MakePinData(),
	}
	for i, v in pairs(misc) do if not info[i] then info[i] = v end end
	return info
end

local function Init()
	if not pin.Init then
		pin.DebugRoot = pin.Make "ScreenGui" {
			Name = "DebuggingV2",
			Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
			ResetOnSpawn = false
		}
		pin.Init = true
	end
end

---- Public Functions

function pin.Make(name)
	local UI = Instance.new(name)
	return function(properties, parent)
		for i, v in pairs(properties) do
			if typeof(i) == "function" then
				i(v, UI)
			else
				if not pin.Signal.isSignal(v) then
					UI[i] = v
				end
			end
		end
		pin.Signal.ApplyToInstance(UI, properties, true)
		if parent then UI["Parent"] = parent; properties["Parent"] = parent end
		return UI, properties
	end
end

function pin.new(adornee : Instance | Vector3 | nil)
	---- Private
	local Pin = {}
	local isRunning = false
	local ChildChanged = Instance.new("BindableEvent")
	local Frame, _ = pin.Make "Frame" {
		Name = "Debugging",
		AnchorPoint = Vector2.new(0.5,0.5),
		Size = UDim2.fromScale(0.1, 0.1),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		[pin.Make "UIListLayout"] = {
			Name = "ListLayout",
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			HorizontalAlignment = Enum.HorizontalAlignment.Left
		},
		Parent = pin.DebugRoot
	}
	---- Public
	Pin.pin = MakePinInfo(adornee, nil, {})

	function Pin:AddChild(element: Instance, properties)
		ChildChanged:Fire(true, element)
		table.insert(Pin.pin.PinData.Children, element)
		return element, properties
	end

	function Pin:RemoveChild(element: Instance)
		ChildChanged:Fire(false, element)
		table.remove(Pin.pin.PinData.Children, table.find(Pin.pin.PinData.Children, element))
	end

	function Pin:Enable()
		if isRunning then return end
		isRunning = true
		task.spawn(function()
			while task.wait() do 
				if not isRunning then print("Stopped"); break end
				local NextPos = UpdatePinPosition(Pin.pin)
				Frame.Position = UDim2.fromOffset(NextPos.X, NextPos.Y)
			end
		end)
	end

	function Pin:Disable()
		if not isRunning then return end
		isRunning = false
	end

	local ChangedConnection = ChildChanged.Event:Connect(function(added, element)
		if not added then
			element:Destroy()
			return
		end
		element.Parent = Frame
	end)

	function Pin:Destroy()
		ChangedConnection:Disconnect()
		Frame:Destroy()
		ChildChanged:Destroy()
		isRunning = false
		Pin.pin = nil
		for i, v in pairs(Pin) do
			Pin[i] = nil
		end
	end

	return Pin
end

Init()
return pin