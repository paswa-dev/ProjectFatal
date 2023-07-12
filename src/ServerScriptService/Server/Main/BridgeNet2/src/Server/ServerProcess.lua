--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local HandleInvalidPlayer = require(script.Parent.HandleInvalidPlayer)
local Output = require(script.Parent.Parent.Utilities.Output)
local TableKit = require(script.Parent.Parent.Parent.TableKit)
local Types = require(script.Parent.Parent.Types)
local RecycledSpawn = require(script.Parent.Parent.Utilities.RecycledSpawn)

local playerList: Types.Set<Player> = {}
local loadingPlayers: Types.Map<Player, number?> = {}
local loadingPlayersQueue: Types.Map<Player, Types.Map<Types.Identifier, Types.Array<Types.Content>>> = {}

local outboundQueue: Types.Array<Types.ServerOutboundPacket> = {}
local inboundQueue: Types.Map<Player, Types.Array<Types.Array<Types.Content>>> = {}

local callbackMap: Types.Map<Types.Identifier, Types.Array<Types.ServerConnectionCallback>> = {}

local ServerProcess = {}

function ServerProcess.start()
	task.spawn(function()
		debug.setmemorycategory("BridgeNet2")
		Output.log("Loading")

		-- Create 2 remote events- one for meta messages (loading, etc.), one for data.
		local metaRemoteEvent = Instance.new("RemoteEvent")
		local dataRemoteEvent = Instance.new("RemoteEvent")

		metaRemoteEvent.Name = "metaRemoteEvent"
		dataRemoteEvent.Name = "dataRemoteEvent"

		metaRemoteEvent.Parent = ReplicatedStorage
		dataRemoteEvent.Parent = ReplicatedStorage

		Players.PlayerAdded:Connect(function(plr)
			-- playerList is for data structure optimization
			playerList[plr] = true

			-- Set up the timeout system- BridgeNet2 should start incrementing this number from now on.
			-- The existance of the number also means that the player is loading.
			loadingPlayers[plr] = 0

			-- Set up the loading queue. This starts putting every single packet in this queue, instead of sending it.
			loadingPlayersQueue[plr] = {}

			-- Start listening to the player for events.
			inboundQueue[plr] = {}
		end)

		Players.PlayerRemoving:Connect(function(plr)
			-- Remove player from every internal data structure
			playerList[plr] = nil
			loadingPlayers[plr] = nil
			loadingPlayersQueue[plr] = nil
			inboundQueue[plr] = nil
		end)

		metaRemoteEvent.OnServerEvent:Connect(function(plr, meta: Types.MetaMessage)
			-- Different meta messages for the future
			if meta == "1" then
				-- Remove the player from the loading stage, and dispatch the loading queue to them.
				loadingPlayers[plr] = nil
				dataRemoteEvent:FireClient(plr, loadingPlayersQueue[plr])
				loadingPlayersQueue[plr] = nil
			end
		end)

		dataRemoteEvent.OnServerEvent:Connect(function(plr, tbl)
			-- Do typechecking before inserting it into the queue- minimize errors in the queue.
			if typeof(tbl) ~= "table" then -- Invalid packet
				HandleInvalidPlayer(plr)
				return
			end

			table.insert(inboundQueue[plr], tbl)
		end)

		local sendStructure: { [Player]: { [Types.Identifier]: { Types.Content } } } = {}

		local function addContentToQueue(player: Player, identifier: Types.Identifier, content: Types.Content)
			local playerContentQueue = sendStructure[player]

			if not playerContentQueue then
				-- Create a content queue for the player, initialize it with the content and identifier provided.
				sendStructure[player] = { [identifier] = { content } }
			else
				if not playerContentQueue[identifier] then
					-- Initialize the specific identifier queue with the content provided
					playerContentQueue[identifier] = { content }
				else
					table.insert(playerContentQueue[identifier], content)
				end
			end
		end

		RunService.PostSimulation:Connect(function()
			debug.profilebegin("BridgeNet2")

			debug.profilebegin("BridgeNet2:Send")
			for _, outbound in outboundQueue do
				-- What kind of data containerValue contains
				local containerKind = outbound.playerContainer.kind

				-- Who gets the content
				local containerValue = outbound.playerContainer.value

				local identifier: string = outbound.id
				local content: unknown = outbound.content

				if containerKind == "single" then
					-- Luau requires a typecast here because it can't interpret containerKind intersection
					local player = containerValue :: Player
					addContentToQueue(player, identifier, content)
				elseif containerKind == "all" then
					for player in playerList do
						addContentToQueue(player, identifier, content)
					end
				elseif containerKind == "except" then
					-- We have to do this typecast to satisfy the typechecker
					for _, plr in containerValue :: { [number]: Player } do
						playerList[plr] = false
					end

					for player, shouldAddContent in playerList do
						if shouldAddContent then
							addContentToQueue(player, identifier, content)
						else
							playerList[player] = true
						end
					end
				elseif containerKind == "set" then
					-- See previous comment
					for _, player in containerValue :: { [number]: Player } do
						addContentToQueue(player, identifier, content)
					end
				end
			end

			for player, contentQueue in sendStructure do
				if loadingPlayers[player] then
					if not loadingPlayersQueue[player] then
						-- Directly initialize this player's loading content queue
						loadingPlayersQueue[player] = contentQueue
					else
						for identifier, content in contentQueue do
							-- Reconcile the old content with the new content
							if not loadingPlayersQueue[player][identifier] then
								loadingPlayersQueue[player][identifier] = content
							else
								TableKit.MergeArrays(loadingPlayersQueue[player][identifier], content)
							end
						end
					end
				else
					dataRemoteEvent:FireClient(player, contentQueue)
				end

				-- Clear every single player's content queue, as it was sent out this frame.
				sendStructure[player] = nil
			end

			table.clear(outboundQueue)
			-- End BridgeNet2 send profile
			debug.profileend()

			debug.profilebegin("BridgeNet2:Receive")

			for plr, queuedPackets in inboundQueue do
				for _, packet in queuedPackets do
					-- Loop every other member, and include nil.
					for i = 1, #packet, 2 do
						-- Every odd member in the array should be content, every even number should be an identifier.
						local content: Types.Content, identifier: Types.Identifier =
							packet[i] :: Types.Content, packet[i + 1] :: Types.Identifier
						-- don't use warnAssert here because we need to run HandleInvalidPlayer
						if typeof(identifier) ~= "string" then
							HandleInvalidPlayer(plr)
							break
						end

						-- Ensure there are connections in the first place before looping
						local callbacks = callbackMap[identifier]
						if not callbacks then
							continue
						end

						for _, callback in callbacks do
							RecycledSpawn(callback, plr, content)
						end
					end
				end

				table.clear(inboundQueue[plr])
			end

			-- End BridgeNet2 receive profile
			debug.profileend()

			-- End BridgeNet2 debug profile
			debug.profileend()
		end)

		Output.log("Loaded")
	end)
end

function ServerProcess.addToQueue(
	playerContainer: Types.PlayerContainer,
	identifier: Types.Identifier,
	content: Types.Content
)
	table.insert(outboundQueue, {
		playerContainer = playerContainer,
		id = identifier,
		content = content,
	})
end

function ServerProcess.setInvalidPlayerFunction(func: (plr: Player) -> ())
	HandleInvalidPlayer = func
end

function ServerProcess.registerBridge(identifier: string)
	callbackMap[identifier] = {}
end

function ServerProcess.connect(identifier: string, callback: Types.ServerConnectionCallback)
	table.insert(callbackMap[identifier], callback)

	-- Disconnect function
	return function()
		local index = table.find(callbackMap[identifier], callback)
		table.remove(callbackMap[identifier], index)
		return
	end
end

return ServerProcess
