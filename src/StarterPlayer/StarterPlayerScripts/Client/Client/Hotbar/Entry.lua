return function(parent, text)
	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.85
	frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(0.233, 1.79)

	local uIStroke = Instance.new("UIStroke")
	uIStroke.Name = "UIStroke"
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uIStroke.Color = Color3.fromRGB(255, 255, 255)
	uIStroke.Thickness = 1.5
	uIStroke.Parent = frame
	frame.Parent = parent
	
	local uITextLabel = Instance.new("TextLabel")
	uITextLabel.Text = text
	uITextLabel.TextScaled = true
	uITextLabel.Font = Enum.Font.RobotoMono
	uITextLabel.BackgroundTransparency = 1
	uITextLabel.Size = UDim2.fromScale(1, 1)
	uITextLabel.TextColor3 = Color3.new(1, 1, 1)
	uITextLabel.Parent = frame
	
	local TextConstraint = Instance.new("UITextSizeConstraint")
	TextConstraint.MaxTextSize = 13
	TextConstraint.MinTextSize = 0
	TextConstraint.Parent = uITextLabel
	
	return frame
end