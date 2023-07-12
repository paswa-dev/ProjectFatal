return function(parent)
	local canvasGroup = Instance.new("CanvasGroup")
	canvasGroup.Name = "CanvasGroup"
	canvasGroup.AnchorPoint = Vector2.new(1, 1)
	canvasGroup.BackgroundColor3 = Color3.fromRGB(255, 181, 121)
	canvasGroup.BackgroundTransparency = 1
	canvasGroup.BorderColor3 = Color3.fromRGB(0, 0, 0)
	canvasGroup.BorderSizePixel = 0
	canvasGroup.Position = UDim2.fromScale(1, 1)
	canvasGroup.Size = UDim2.fromScale(0.306, 0.0698)

	local uIGridLayout = Instance.new("UIGridLayout")
	uIGridLayout.Name = "UIGridLayout"
	uIGridLayout.CellSize = UDim2.fromScale(0.15, 1)
	uIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIGridLayout.Parent = canvasGroup

	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint.AspectRatio = 7
	uIAspectRatioConstraint.Parent = canvasGroup
	
	canvasGroup.Parent = parent
	
	return canvasGroup
end