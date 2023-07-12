local Player = game:GetService("Players").LocalPlayer
local PlayerGUI = Player:WaitForChild("PlayerGui")

local function Gui()
	local Bin = Instance.new("ScreenGui")
	Bin.Name = "DebugVisual"
	Bin.IgnoreGuiInset = true
	Bin.Parent = PlayerGUI
	return Bin
end

local Debug = {
	Bin = nil :: ScreenGui,
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
	Debug.Bin = Gui()
end

return Debug
