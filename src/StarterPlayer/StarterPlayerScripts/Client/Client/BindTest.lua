local get = _G.get

local Binding = get("Binding")

local BindTest = {}

function BindTest.Init()
	local Directive = {
		Run = function(state)
			if state == Enum.UserInputState.End then
				print("Requested to stop running!")
			end
		end,
		Dash = function(state)
			if state == Enum.UserInputState.Begin then
				print("Request to dash!")
			end
		end,
		Zoom = function(state)
			if state == Enum.UserInputState.Change then
				print("Zoom is changing currently...")
			end
		end,
	}

	Binding.map({
		[Enum.KeyCode.LeftShift] = Directive.Run,
		[Enum.KeyCode.LeftControl] = Directive.Dash,
		[Enum.UserInputType.MouseWheel] = Directive.Zoom,
	})

	--// Change existing item?

	Binding.hardMap({
		[Enum.KeyCode.LeftShift] = Binding._nil,
	})
	--// Add non existing item. Wont work if the item does not exist.

	Binding.softMap({
		[Enum.KeyCode.LeftShift] = function(state)
			print("I tried to overwrite")
		end,
	}) --// Will not work because the value exist. Only adds something if it doesnt exist.

	Binding.crossMap({
		[Enum.KeyCode.LeftControl] = function(state)
			print("I edited this!")
		end,
	}) --// Rewrite data without deleting it. Adding, editing, or removing it...
end

return BindTest
