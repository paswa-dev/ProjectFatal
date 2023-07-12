local RS = game:GetService("RunService")
local RSTORAGE = game:GetService("ReplicatedStorage")
local IS_SERVER = RS:IsServer()

local function SRemote(name, fetch)
	if fetch then return RSTORAGE:FindFirstChild(name) end
	local R = Instance.new("RemoteEvent")
	R.Name = name
	R.Parent = RSTORAGE
	return R
end

local Remote: RemoteEvent = IS_SERVER and SRemote("DynamicSounds", false) or SRemote("DynamicSounds", true)
local Dynamic = {
	OnReplicate = Remote and Remote.OnServerEvent or nil
}

local MT = {__index = Dynamic}

local function Root()
	local Part = Instance.new "Part"
	Part.Transparency = 1
	Part.Anchored = true
	Part.CanCollide = false
	Part.CanTouch = false
	Part.CanQuery = false
	Part.Parent = workspace
	return Part
end

function Dynamic.new(sound: Sound, threshold)
	local config = {}
	config.Sound = sound
	config.Root = Root()
	config.ReplicationDistance = IS_SERVER and 100 or nil
	
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	
	return setmetatable(config, MT)
end

function Dynamic:Node(position)
	local Attachment = Instance.new("Attachment")
	Attachment.CFrame = CFrame.new(self.Root.CFrame:PointToObjectSpace(position))
	Attachment.Parent = self.Root
	return Attachment
end

function Dynamic:Increment(sound: Sound, position)
	local Node = position and self:Node(position) or game.SoundService
	sound.Parent = Node
	sound:Play()
	task.delay(sound.TimeLength, function()
		if position then Node:Destroy() else sound:Destroy() end
	end)
end

function Dynamic:Spawn(position)
	local sound = self.Sound:Clone()
	self:Increment(sound, position)
end

return Dynamic
