local get = _G.get

local Binding = get("Binding")

local BindTest = {}

function BindTest.Init()
	local Directive = {
		Run = function(state)
			print(state)
		end,
	}

	Binding.map({
		[Enum.KeyCode.LeftShift] = Directive.Run,
	})
end

return BindTest
