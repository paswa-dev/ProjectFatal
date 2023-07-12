local CS = game:GetService("CollectionService")
local TagAllocation = {
	--["TestTag"] = -1 --// Infinite
}
local tag = {
	Tags = {} :: {[string]: TagStore},
	TagType = {
		Added = 0,
		Removed = 1
	},
	Started = false,
	AllocateTags = false
}

type func = (...any) -> ()

export type TagStore = {
	tag: string,
	New: RBXScriptSignal,
	Removed: RBXScriptSignal,
	NewConnection: RBXScriptConnection?,
	RemovedConnection: RBXScriptConnection?,
	Connected: boolean,
	instructions: {func}
}

local function CallAll(t, ...)
	for _, v in next, t do
		v(...)
	end
end

local function NewSetup(tag_name)
	tag.Tags[tag_name].NewConnection = tag.Tags[tag_name].New:Connect(function(instance)
		CallAll(tag.Tags[tag_name].instructions, instance, tag.TagType.Added)
	end)

	tag.Tags[tag_name].RemovedConnection = tag.Tags[tag_name].Removed:Connect(function(instance)
		CallAll(tag.Tags[tag_name].instructions, instance, tag.TagType.Removed)
	end)
	tag.Tags[tag_name].Connected = true
end

local function __init()
	if tag.Started then return end
	for _, tag_name in next, CS:GetAllTags() do
		tag.Tags[tag_name] = {
			tag = tag_name,
			New = CS:GetInstanceAddedSignal(tag_name),
			Removed = CS:GetInstanceRemovedSignal(tag_name),
			Connected = false,
			instructions = {}
		} :: TagStore
		if tag.AllocateTags then
			if TagAllocation[tag_name] == nil then return end
			tag.Tags[tag_name].instructions = TagAllocation[tag_name] == -1 and {} or table.create(TagAllocation[tag_name])
			NewSetup(tag_name)
		else
			NewSetup(tag_name)
		end
		
	end
	tag.Started = true
end

function tag.Start()
	for _, tag_name in next, CS:GetAllTags() do
		for _, object in next, CS:GetTagged(tag_name) do
			CallAll(tag.Tags[tag_name].instructions, object, tag.TagType.Added)
		end
	end
end

function tag.Get(tag_name: string) --// Returns raw TagStore data.
	return tag.Tags[tag_name]
end

function tag.Set(tag_name: string, callback: func) --// Directly sets the signals. (Returns 2 different CollectionType)
	if tag.Tags[tag_name] then
		table.insert(tag.Tags[tag_name].instructions, callback)
	end
end

__init()
return tag
