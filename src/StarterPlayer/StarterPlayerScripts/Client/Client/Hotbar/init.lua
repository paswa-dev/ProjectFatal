local Framework = require(game:GetService("ReplicatedFirst").Framework)
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Binds = Framework.Get("Common", "Binds")
local Signal = Framework.Get("Dependents", "FastSignal")

local Bar = require(script.Bar)
local Entry = require(script.Entry)

local Enumeration = {
	"One", "Two", "Three", "Four", "Five", "Six"
}

local function NewUI()
	local Gui = Instance.new("ScreenGui")
	Gui.Parent = PlayerGui
	Gui.Name = "Hotbar"
	Gui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	Gui.IgnoreGuiInset = true
	return Gui
end

local hotbar = {}
hotbar.Gui = NewUI()
hotbar.Bar = nil
hotbar.Data = nil

function hotbar.Create()
	if hotbar.Data then return hotbar.Data else hotbar.Bar = Bar(hotbar.Gui) end
	local data = {}
	data.Selected = 0
	data.OnEquip = Signal.new()
	data.OnUnequip = Signal.new()
	data.Binding = Binds.new()
	
	local function ObjectOfIndex(index)
		local Frame = hotbar.Bar
		return Frame[tostring(index)]
	end
	
	local function TextObjectOfIndex(index)
		local Frame = ObjectOfIndex(index)
		return Frame.TextLabel
	end
	
	local function EquipIndex(index)
		local SelectedFrame = ObjectOfIndex(index)
		--// Change what it looks like
	end
	
	local function UnequipIndex(index)
		local SelectedFrame = ObjectOfIndex(index)
		--// Change what it looks like
	end
	
	local function GenerateEntries()
		for i=1, 6 do
			local NewEntry = Entry(hotbar.Bar, "")
			NewEntry.Name = i
		end
	end
	
	local function EstablishData()
		for index, Enumer in next, Enumeration do
			data.Binding.Bind(Enum.KeyCode[Enumer], function(state)
				if state == 0 then --// Equipped
					if data.Selected ~= index then
						if data.Selected ~= 0 then
							UnequipIndex(data.Selected)
							data.OnUnequip:Fire(data.Selected, TextObjectOfIndex(data.Selected).Text)
						end
						EquipIndex(index)
						data.Selected = index
						data.OnEquip:Fire(index, TextObjectOfIndex(index).Text)
					end
				end
			end)
		end
	end
	
	function data.Set(index, name)
		local Object = TextObjectOfIndex(index)
		Object.Text = name
	end
	
	function data:Hide()
		data.Binding.UnbindAll()
		hotbar.Bar.Position = UDim2.fromScale(-1, -1)
	end
	
	function data:Unhide()
		EstablishData()
		hotbar.Bar.Position = UDim2.fromScale(1, 1)
	end
	
	GenerateEntries()
	EstablishData()
	hotbar.Data = data
	return data
end

return hotbar