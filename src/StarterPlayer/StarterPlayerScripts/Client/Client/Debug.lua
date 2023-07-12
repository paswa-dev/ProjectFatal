local Debris = game:GetService("Debris")
local Logging = game:GetService("LogService")
local Player = game:GetService("Players").LocalPlayer

local get = _G.get
local Fusion = get("fusion")

local PlayerGUI = Player:WaitForChild("PlayerGui")

local ColorCodes = {
	[Enum.MessageType.MessageError] = Color3.new(0.658823, 0.121568, 0.121568),
	[Enum.MessageType.MessageInfo] = Color3.new(0.356862, 0.560784, 0.094117),
	[Enum.MessageType.MessageOutput] = Color3.new(1, 1, 1),
	[Enum.MessageType.MessageWarning] = Color3.new(0.894117, 0.878431, 0.090196),
}

local function Screen()
	return Fusion.New("ScreenGui")({
		Name = "DebugVisual",
		IgnoreGuiInset = true,
		Parent = PlayerGUI,
	})
end

local function Display(Parent)
	return Fusion.New("Frame")({
		Name = "MessageDump",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 1,
		[Fusion.Children] = Fusion.New("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),

		Parent = Parent,
	})
end

local function Entry(text, colour, parent)
	return Fusion.New("TextLabel")({
		Font = Enum.Font.Code,
		AutomaticSize = Enum.AutomaticSize.XY,
		FillDirection = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		TextScaled = true,
		BackgroundTransparency = 1,
		TextColor3 = colour,
		Text = text,
		[Fusion.Children] = Fusion.New("UITextSizeConstraint")({
			MaxTextSize = 13,
			MinTextSize = 0,
		}),
		Parent = parent,
	})
end

local Debug = {
	Gui = nil :: ScreenGui,
	Interface = nil :: Frame,
}

do
	_G.DebugControl = Instance.new("BoolValue")
	_G.DebugControl.Value = false
	_G.DebugControl.Changed:Connect(function(v)
		if v then
			Debug.Hide()
		else
			Debug.Unhide()
		end
	end)
end

function Debug.Init()
	Debug.Gui = Screen()
	Debug.Interface = Display(Debug.Gui)

	local function MessageOut(message, messageType)
		local Color = ColorCodes[messageType]
		Debris:AddItem(Entry(message, Color, Debug.Interface), 4)
	end

	Logging.MessageOut:Connect(MessageOut)
end

return Debug
