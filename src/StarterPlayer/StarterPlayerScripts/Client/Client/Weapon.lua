--local RFirst = game:GetService("ReplicatedFirst")
--local RS = game:GetService("RunService")
--local UIS = game:GetService("UserInputService")
--UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
--UIS.MouseIconEnabled = false

--local Framework = require(RFirst.Framework)

--local Bindings = Framework.Get("Common", "UISWrapper")

--local ObjectWrapper = Framework.Get("Utils", "ObjectHandler")
--local MathUtils = Framework.Get("Utils", "MathUtils")
--local StateManage = Framework.Get("Utils", "State")
--local Clock = Framework.Get("Utils", "Clock")

--local FastSignal = Framework.Get("Dependents", "FastSignal")

--local RSWrapper = Framework.Get("Common", "RSWrapper")
--local Spring = Framework.Get("Common", "Spring")

--local Camera = Framework.Camera
--local Player = Framework.Player
--local Character = Framework.Character
--local PlayerState = StateManage.new(Player)

--local WV = {}

--local function CreateConfiguration(Weapon)
--	local config = {
--		Model = Weapon,
--		Animator = Weapon:FindFirstChildWhichIsA("Animator", true),
--		CFrame = CFrame.identity,
--		Center = Camera.ViewportSize/2, --// Middle of screen
--		Mouse = Vector2.zero,

--		Aiming = PlayerState:Signal("Aiming", false),
--		Running = PlayerState:Signal("Running", false),
--		Moving = PlayerState:Signal("Moving", false),
--		Firing = PlayerState:Signal("Firing", false),

--		OnFire = FastSignal.new(),

--		RSID = RSWrapper.NewID(),
--		Binds = Bindings.new()
--	}
--	return config
--end

--local function EstablishBinds(config)
--	config.Binds.Bind(Enum.UserInputType.MouseButton1, function(action)
--		if action == config.Binds.Types.Press and not config.Firing() then
--			config.Firing(true)
--		else
--			config.Firing(false)
--		end
--	end)

--	config.Binds.Bind(Enum.KeyCode.Q, function(action)
--		if action == config.Binds.Types.Press then
--			config.Aiming(true)
--			config.Running(false)
--		else
--			config.Aiming(false)
--		end
--	end)
--end

--function WV.new(data)
--	local Weapon = data.Model:Clone() :: PVInstance; Weapon.Parent = Camera
--	local WeaponWrapper = ObjectWrapper.wrap(Weapon)
--	local Aimpoint = Weapon:FindFirstChildWhichIsA("Attachment", true)
--	WeaponWrapper:Rig(Weapon.HumanoidRootPart)

--	local config = CreateConfiguration(Weapon)

--	local Values = {}
--	Values.RPS = 60/data.Firerate
--	Values.LastShot = 0
--	config.Clock = Clock.new(function(elapsed)
--		if (elapsed - Values.LastShot) > Values.RPS then
--			config:Fire()
--			Values.LastShot = elapsed
--		end
--	end)

--	--// Springs (Allow Data parameters to take over these)
--	local OffsetSpring = Spring.new(data.Offset, 10, 1, false)
--	local MoveSpring = Spring.new(Vector3.zero, 10, 1, false)
--	local Recoil = Spring.new(Vector3.zero, 15, 0.5, false)
--	local RecoilAngle = Spring.new(Vector3.zero, 4, 0.8, false)
--	local RecoilMouse = Spring.new(Vector2.zero, 10, 1, false)
--	local Sway = Spring.new(Vector2.zero, Vector2.new(4, 15), Vector2.new(0.9, 1.5), true)

--	local ExternalOffset = Spring.new(Vector3.zero, 10, 1, false)
--	local ExternalRotation = Spring.new(Vector3.zero, 10, 1, false)

--	local function GetNewCFrameToMousePoint()
--		local CF = Camera.CFrame
--		local Mouse = config.Mouse + config.Center
--		local ScreenRay = Camera:ScreenPointToRay(Mouse.X, Mouse.Y, 100)
--		return CFrame.new(CF.Position, CF.Position + ScreenRay.Direction)
--	end

--	local function RetrieveOffsetFromAimpoint()
--		local ModelCF = WeaponWrapper.CFrame
--		local AimpointCF = Aimpoint.WorldCFrame
--		local Offset = ModelCF:ToObjectSpace(AimpointCF)
--		return -(Offset.Position)
--	end

--	local function SetupSignals()
--		local LastShot = 0
--		local ClockObject = Clock.new(function(elapsed)
--			if (elapsed - LastShot) > Values.RPS then
--				config:Fire()
--				LastShot = elapsed
--			end
--		end)
--		config.Firing:Changed(function(new_value)
--			if new_value then ClockObject:Start() else ClockObject:Stop() end
--		end)
--	end

--	local function UpdateAttributeChanges()
--		local MouseDelta = MathUtils.Clamp2(UIS:GetMouseDelta() / 80, Vector2.new(-3, -3), Vector2.new(1, 0.05))
--		OffsetSpring._spring.Target = config.Aiming() and Vector3.zero or data.Offset
--		MoveSpring._spring.Target = config.Aiming() and RetrieveOffsetFromAimpoint() or Vector3.zero
--		Sway._spring.Target = MouseDelta
--		config.Mouse = RecoilMouse._spring.Position
--	end

--	function config:Fire()
--		config.OnFire:Fire()
--		RecoilAngle._spring:Impulse(
--			Vector3.new(
--				math.rad(MathUtils.Rand(data.ARange.X.X, data.ARange.X.Y, true)),
--				math.rad(MathUtils.Rand(data.ARange.Y.X, data.ARange.Y.Y, true)),
--				0
--			)
--		)
--		Recoil._spring:Impulse(
--			Vector3.new(
--				MathUtils.Rand(-0.1, 0.1, true),
--				MathUtils.Rand(-0.1, 0.1, true),
--				6
--			)
--		)
--		RecoilMouse._spring:Impulse(Vector2.new(0, -data.Recoil))
--	end

--	function config:SetMaskOffset(Position, Rotation, Override)
--		if not Position or not Rotation then return end
--		local Index = Override and "Position" or "Target"
--		ExternalOffset._spring[Index] = Position
--		ExternalRotation._spring[Index] = Rotation
--	end

--	RSWrapper.Add(config.RSID, function(dt)
--		UpdateAttributeChanges()
--		local CF = GetNewCFrameToMousePoint()
--		CF = CF:ToWorldSpace(CFrame.new(OffsetSpring._spring.Position))
--		CF = CF:ToWorldSpace(CFrame.new(ExternalOffset._spring.Position))
--		CF = CF:ToWorldSpace(CFrame.new(MoveSpring._spring.Position))

--		CF = CF * CFrame.Angles(MathUtils.UnpackVector(ExternalRotation._spring.Position))

--		CF = CF * CFrame.Angles(MathUtils.UnpackVector(Sway._spring.Position/Vector2.new(3,1), "YXX", "__-"))
--		CF = CF * CFrame.Angles(MathUtils.UnpackVector(RecoilAngle._spring.Position))
--		CF = CF:ToWorldSpace(CFrame.new(Recoil._spring.Position))
--		WeaponWrapper.CFrame = CF
--	end)

--	EstablishBinds(config)
--	SetupSignals()

--	return setmetatable(config, {__index = WV})
--end

--function WV:Kill()
--	self.Clock:Stop()
--	self.Binds.UnbindAll()
--	RSWrapper.Remove(self.RSID)
--	self.OnFire:DisconnectAll()
--	self.Model:Destroy()
--end

--function WV:LoadAnimation(animation)
--	if not self.Animator then return end
--	return self.Animator:LoadAnimation(animation)
--end

--function WV:SetFiringSound()

--end

--return WV

return {}
