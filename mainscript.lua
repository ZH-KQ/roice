--██████╗░██╗░█████╗░███████╗  ██╗░░██╗██╗░░░██╗██████╗░
--██╔══██╗██║██╔══██╗██╔════╝  ██║░░██║██║░░░██║██╔══██╗
--██████╔╝██║██║░░╚═╝█████╗░░  ███████║██║░░░██║██████╦╝
--██╔══██╗██║██║░░██╗██╔══╝░░  ██╔══██║██║░░░██║██╔══██╗
--██║░░██║██║╚█████╔╝███████╗  ██║░░██║╚██████╔╝██████╦╝
--╚═╝░░╚═╝╚═╝░╚════╝░╚══════╝  ╚═╝░░╚═╝░╚═════╝░╚═════╝░

--//Check Game ID
if game.PlaceId ~= 85896571713843 then return end

--//Dependencies
local GithubRepository = 'https://raw.githubusercontent.com/ZH-KQ/roice/refs/heads/main/'
local GithubSource = loadstring(game:HttpGet(GithubRepository .. 'source.lua'))()
local ThemeManager = loadstring(game:HttpGet(GithubRepository .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(GithubRepository .. 'addons/SaveManager.lua'))()

--//Configuration Variables
local AutoBubble = false
local AutoBubbleDelay = 0
local AutoCollectCollectibles = false
local AutoCollectPickups = false
local AutoCollectPlaytimeRewards = false
local SelectedEgg = "--"
local AutoOpenEggs = false
local AutoBuyBlackMarket = false
local AutoBuyAlienShop = false
local DisableEggHatchAnimation = false

--//RobloxServices
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

--// Variables
local Player = game.Players.LocalPlayer
local RenderedFolder = game.Workspace:WaitForChild("Rendered")
local WorldMap = Player.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("WorldMap")
local WheelSpin = Player.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("WheelSpin")
local EggHatchFrame = Player.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Hatching")
local SelectableEggsCollection = {}

--// Functions
local function isUUID(name)
	return string.match(name, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end
local function GetFullPath(instance)
	local path = instance.Name
	local parent = instance.Parent
	while parent and parent ~= game do
		path = parent.Name .. "." .. path
		parent = parent.Parent
	end
	return path
end
local function CollectPickups()
	for i, v in next, game:GetService("Workspace").Rendered:GetChildren() do
		if v.Name == "Chunker" then
			for i2, v2 in next, v:GetChildren() do
				local Part, HasMeshPart = v2:FindFirstChild("Part"), v2:FindFirstChildWhichIsA("MeshPart");
				local HasStars = Part and Part:FindFirstChild("Stars");
				local HasPartMesh = Part and Part:FindFirstChild("Mesh");
				if HasMeshPart or HasStars or HasPartMesh then
					game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Pickups"):WaitForChild("CollectPickup"):FireServer(v2.Name);
					v2:Destroy();
				end;
			end;
		end;
	end;
end;
local function RefreshEggList()
	table.clear(SelectableEggsCollection)
	table.insert(SelectableEggsCollection, "--")
	local RenderedFolder = game.Workspace:FindFirstChild("Rendered")
	for _, instance in ipairs(game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Eggs"):GetChildren()) do
		if instance.Name:find("Egg") and not instance.Name:find("Golden") and not table.find(SelectableEggsCollection, instance.Name) then
			if RenderedFolder then
				for _, ChunkerFolder in pairs(RenderedFolder:GetChildren()) do
					if ChunkerFolder.Name == "Chunker" then
						local FoundEgg = ChunkerFolder:FindFirstChild(instance.Name)
						if FoundEgg and FoundEgg:FindFirstChild("Plate") then
							table.insert(SelectableEggsCollection, FoundEgg.Name)
							break
						end
					end
				end
			end
		end
	end
	return SelectableEggsCollection
end

local function TeleportBypass2(Character, TargetPosition)
	local Humanoid = Character and Character:FindFirstChild("Humanoid")
	local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
	if not TargetPosition or not HumanoidRootPart or not Humanoid then
		warn("Information mismatch. Teleport not started.")
	else
		if HumanoidRootPart then
			local CurrentYPosition = HumanoidRootPart.Position.Y
			local TargetYPosition = TargetPosition.Y
			if math.abs(CurrentYPosition - TargetYPosition) > 5 then
				print("no")
			end
		end
		local speed = Humanoid.WalkSpeed
		local reached = false
		Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		local originalCollisions = {}
		for _, part in ipairs(Character:GetChildren()) do
			if part:IsA("BasePart") then
				originalCollisions[part] = part.CanCollide
				part.CanCollide = false
			end
		end
		for _, child in ipairs(HumanoidRootPart:GetChildren()) do
			if child:IsA("BodyVelocity") then
				child:Destroy()
			end
		end
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyVelocity.Parent = HumanoidRootPart

		local noclipConnection
		noclipConnection = RunService.Stepped:Connect(function()
			if Character ~= nil then
				for _, child in pairs(Character:GetDescendants()) do
					if child:IsA("BasePart") and child.CanCollide == true then
						child.CanCollide = false
					end
				end
			end
		end)
		RunService.RenderStepped:Connect(function(dt)
			if not Character or not Humanoid or not HumanoidRootPart or reached then return end
			local toTarget = TargetPosition - HumanoidRootPart.Position
			local horizontal = Vector3.new(toTarget.X, toTarget.Y, toTarget.Z)
			local distance = horizontal.Magnitude
			if distance < 0.2 then
				reached = true
				bodyVelocity:Destroy()
				noclipConnection:Disconnect()
				for part, canCollide in pairs(originalCollisions) do
					part.CanCollide = canCollide
				end
				Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				return
			end
			local step = math.min(speed, distance / dt)
			local moveDirection = horizontal.Unit * step
			bodyVelocity.Velocity = moveDirection
		end)
	end
end

--//Startup
RefreshEggList()

--//WindowCreation
local Window = GithubSource:CreateWindow({
	-- Set Center to true if you want the menu to appear in the center
	-- Set AutoShow to true if you want the menu to appear when it is created
	-- Position and Size are also valid options here
	-- but you do not need to define them unless you are changing them :)
	Title = 'BGSI Rice Hub made by Ricee [🍚]',
	Center = true,
	AutoShow = true,
	TabPadding = 8,
	Size = UDim2.fromOffset(550, 400)
})

--//TabCreation
local Tabs = {
	['Main'] = Window:AddTab('Main'),
	['Teleports'] = Window:AddTab('Teleports'),
	['UI Settings'] = Window:AddTab('UI Settings'),
}

--//Coordinates
local CoordinateGroupBox = Tabs.Main:AddLeftGroupbox('Coordinates:')
local CoordinateLabel = CoordinateGroupBox:AddLabel("X: 0  Y: 0  Z: 0", true)
RunService.RenderStepped:Connect(function()
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	if HumanoidRootPart then
		local Position = HumanoidRootPart.Position
		local CoordinateText = string.format("X: %.1f  Y: %.1f  Z: %.1f", Position.X, Position.Y, Position.Z)
		CoordinateLabel:SetText(CoordinateText)
	end
end)

--//AutoBubble
local AutoBubbleGroupBox = Tabs.Main:AddLeftGroupbox('Auto Bubble')
AutoBubbleGroupBox:AddToggle('AutoBubble', {
	Text = 'Auto Bubble',
	Default = false,
	Callback = function(Value)
		AutoBubble = Value
		if AutoBubble then
			task.spawn(function()
				while AutoBubble do
					local Arguments = { "BlowBubble" }
					ReplicatedStorage:WaitForChild("Shared")
						:WaitForChild("Framework")
						:WaitForChild("Network")
						:WaitForChild("Remote")
						:WaitForChild("Event")
						:FireServer(unpack(Arguments))
					task.wait(AutoBubbleDelay)
				end
			end)
		end
	end
})
AutoBubbleGroupBox:AddInput('AutoBubbleDelay', {
	Default = '', -- Default text in the textbox
	Numeric = true, -- Sets if the textbox only allows numbers
	Finished = true,  -- Sets if the textbox only calls callback if you pressed enter
	Text = 'Auto Bubble Delay',
	Placeholder = 'Delay in seconds', -- Sets the placeholder text when the box is empty
	Callback = function(Value)
		if type(tonumber(Value)) == "number" then
			AutoBubbleDelay = Value
			GithubSource:Notify("Set auto bubble delay to "..Value.." seconds!", 5)
		else
			AutoBubbleDelay = 0
			GithubSource:Notify("Set auto bubble delay to 0 seconds!", 5)
		end
	end
})
--//AutoCollect
local AutoCollectGroupBox = Tabs.Main:AddLeftGroupbox('Auto Collect')
AutoCollectGroupBox:AddToggle('AutoCollectCollectibles', {
	Text = 'Auto Collect Collectibles',
	Default = false,
	Callback = function(Value)
		AutoCollectCollectibles = Value
		if AutoCollectCollectibles then
			task.spawn(function()
				while AutoCollectCollectibles do
					local WorldMapActive = false
					local WheelSpinActive = false
					if WorldMap.Visible then 
						WorldMapActive = true
					end
					local RemoteEvent = ReplicatedStorage
						:WaitForChild("Shared")
						:WaitForChild("Framework")
						:WaitForChild("Network")
						:WaitForChild("Remote")
						:WaitForChild("Event")
					for _, Chest in ipairs(workspace.Rendered.Chests:GetChildren()) do
						local Island = Chest:GetAttribute("Island")
						if Island then
							local Arguments = {"ClaimChest", Chest.Name, true}
							WorldMap.Visible = true
							RemoteEvent:FireServer(unpack(Arguments))
							if WorldMapActive == false then
								WorldMap.Visible = false
							end
							task.wait(1)
						end
					end
					if WheelSpin.Visible then 
						WheelSpinActive = true
					end
					WheelSpin.Visible = true
					ReplicatedStorage
						:WaitForChild("Shared")
						:WaitForChild("Framework")
						:WaitForChild("Network")
						:WaitForChild("Remote")
						:WaitForChild("Event"):FireServer("ClaimFreeWheelSpin")
					if WheelSpinActive == false then
						WheelSpin.Visible = false
					end
					task.wait(5)
				end
			end)
		end
	end
})
AutoCollectGroupBox:AddToggle('AutoCollectPickups', {
	Text = 'Auto Collect Pickups',
	Default = false,
	Callback = function(Value)
		AutoCollectPickups = Value
		if AutoCollectPickups then
			task.spawn(function()
				while AutoCollectPickups do
					CollectPickups()
					task.wait(1)
				end
			end)
		end
	end
})
AutoCollectGroupBox:AddToggle('AutoCollectPlaytimeRewards', {
	Text = 'Auto Collect Playtime Rewards',
	Default = false,
	Callback = function(Value)
		AutoCollectPlaytimeRewards = Value
		if AutoCollectPlaytimeRewards then
			task.spawn(function()
				while AutoCollectPlaytimeRewards do
					for i = 1, 9 do
						local args = {
							"ClaimPlaytime",
							i
						}
						game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Function"):InvokeServer(unpack(args))
						task.wait(0.1)
					end
					task.wait(5)
				end
			end)
		end
	end
})
local AutoEggsGroupBox = Tabs.Main:AddRightGroupbox('Auto Eggs')
AutoEggsGroupBox:AddDropdown('SelectedEgg', {
	Values = SelectableEggsCollection,
	Default = 1,
	Multi = false, -- Sets if multiple options could be pressed
	Text = 'Selected Egg',
	Callback = function(Value)
		SelectedEgg = Value
	end
})
local RefreshEggSelectionButton = AutoEggsGroupBox:AddButton({
	Text = 'Refresh Egg Selection',
	Func = function()
		SelectedEgg = "--"
		Options.SelectedEgg:SetValue("--")
		Options.SelectedEgg:CloseDropdown()
		local InfinityEggLocation = nil
		local Character = Player.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		for _, folder in ipairs(game.Workspace:WaitForChild("Rendered"):GetChildren()) do
			if folder:IsA("Folder") and folder.Name == "Chunker" then
				InfinityEggLocation = folder:FindFirstChild("Infinity Egg")
				if InfinityEggLocation then break end
			end
		end
		if InfinityEggLocation then
			local InfinityEggPlate = InfinityEggLocation:FindFirstChild("Plate")
			if InfinityEggPlate then
				local TargetPosition = InfinityEggPlate.Position + Vector3.new(0, 5, 0)
				local toTarget = TargetPosition - HumanoidRootPart.Position
				local horizontal = Vector3.new(toTarget.X, 0, toTarget.Z)
				local distance = horizontal.Magnitude
				TeleportBypass2(Character,TargetPosition)
			end
		end
		local RefreshedEggList = RefreshEggList()
		if Options.SelectedEgg then
			Options.SelectedEgg:SetValues(RefreshedEggList)
			Options.SelectedEgg:SetValue("--")
		else
			warn("SelectedEgg dropdown or RefreshDropdown method not found.")
		end
	end,
})
AutoEggsGroupBox:AddToggle('AutoOpenEggs', {
	Text = 'Auto Open Eggs',
	Default = false,
	Callback = function(Value)
		AutoOpenEggs = Value
		if AutoOpenEggs then
			task.spawn(function()
				while AutoOpenEggs do
					local Character = Player.Character
					local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
					local EggLocation = nil
					if Character and HumanoidRootPart then
						if SelectedEgg == "--" then return end
						for _, folder in ipairs(game.Workspace:WaitForChild("Rendered"):GetChildren()) do
							if folder:IsA("Folder") and folder.Name == "Chunker" then
								EggLocation = folder:FindFirstChild(SelectedEgg)
								if EggLocation then break end
							end
						end
						if EggLocation then
							local EggPlate = EggLocation:FindFirstChild("Plate")
							if EggPlate then
								local TargetPosition = EggPlate.Position + Vector3.new(0, 5, 0)
								local toTarget = TargetPosition - HumanoidRootPart.Position
								local horizontal = Vector3.new(toTarget.X, 0, toTarget.Z)
								local distance = horizontal.Magnitude
								if distance < 13 then
									VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
									task.wait(0.0001)
									VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
								else
									if not Character:FindFirstChildOfClass("BodyVelocity") then
										TeleportBypass2(Character,TargetPosition)
									end
								end
							end
						else
							GithubSource:Notify("Egg not found, teleport to spawn and refresh selectable eggs.", 5)
							return
						end
					end
					task.wait(0.1)
				end
			end)
		end
	end
})
AutoEggsGroupBox:AddToggle('DisableEggHatchAnimation', {
	Text = 'Disable Egg Hatch Animation',
	Default = false,
	Callback = function(Value)
		DisableEggHatchAnimation = Value
		if DisableEggHatchAnimation then
			task.spawn(function()
				while DisableEggHatchAnimation do
					if EggHatchFrame.Visible then
						EggHatchFrame.Visible = false
					end
					task.wait(0.0001)
				end
			end)
		end
	end
})

local MerchantsGroupBox = Tabs.Main:AddRightGroupbox('Merchants')
MerchantsGroupBox:AddToggle('AutoBuyBlackMarket', {
	Text = 'Auto Buy Black Market',
	Default = false,
	Callback = function(Value)
		AutoBuyBlackMarket = Value
		if AutoBuyBlackMarket then
			task.spawn(function()
				while AutoBuyBlackMarket do
					for i = 1, 3 do
						local Arguments = {
							"BuyShopItem",
							"shard-shop",
							i
						}
						ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(Arguments))
						task.wait(1)
					end
					task.wait(4)
				end
			end)
		end
	end
})
MerchantsGroupBox:AddToggle('AutoBuyAlienShop', {
	Text = 'Auto Buy Alien Shop',
	Default = false,
	Callback = function(Value)
		AutoBuyAlienShop = Value
		if AutoBuyAlienShop then
			task.spawn(function()
				while AutoBuyAlienShop do
					for i = 1, 3 do
						local Arguments = {
							"BuyShopItem",
							"alien-shop",
							i
						}
						ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(Arguments))
						task.wait(1)
					end
					task.wait(4)
				end
			end)
		end
	end
})
local MiscellaneousGroupBox = Tabs.Main:AddRightGroupbox('Miscellaneous')
local FPS Booster = MiscellaneousGroupBox:AddButton({
	Text = 'FPS Booster',
	Func = function()
		pcall(function()
			local Terrain = workspace:FindFirstChildOfClass('Terrain')
			Terrain.WaterWaveSize = 0
			Terrain.WaterWaveSpeed = 0
			Terrain.WaterReflectance = 0
			Terrain.WaterTransparency = 0
			game.Lighting.GlobalShadows = false
			game.Lighting.FogEnd = 9e9
			settings().Rendering.QualityLevel = 1
			for i,v in pairs(game:GetDescendants()) do
				if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
					v.Material = "Plastic"
					v.Reflectance = 0
				elseif v:IsA("Decal") then
					v.Transparency = 1
				elseif v:IsA("Texture") then
					v.Transparency = 1
				elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
					v.Lifetime = NumberRange.new(0)
				elseif v:IsA("Explosion") then
					v.BlastPressure = 1
					v.BlastRadius = 1
				end
			end
			for i,v in pairs(game.Lighting:GetDescendants()) do
				if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
					v.Enabled = false
				end
			end
			workspace.DescendantAdded:Connect(function(child)
				task.spawn(function()
					if child:IsA('ForceField') then
						RunService.Heartbeat:Wait()
						child:Destroy()
					elseif child:IsA('Sparkles') then
						RunService.Heartbeat:Wait()
						child:Destroy()
					elseif child:IsA('Smoke') or child:IsA('Fire') then
						RunService.Heartbeat:Wait()
						child:Destroy()
					end
				end)
			end)
		end)
	end,
	DoubleClick = true,
})

local TeleportsGroupBox = Tabs.Teleports:AddLeftGroupbox('Teleports')
local World1Label = TeleportsGroupBox:AddLabel("World 1", true)
local TeleportSpawn = TeleportsGroupBox:AddButton({
	Text = 'Teleport To Spawn',
	Func = function()
		local args = {
			"Teleport",
			"Workspace.Worlds.The Overworld.PortalSpawn"
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
	end,
	DoubleClick = false,
})
local TeleportFloatingIsland = TeleportsGroupBox:AddButton({
	Text = 'Teleport To Floating Island',
	Func = function()
		local args = {
			"Teleport",
			"Workspace.Worlds.The Overworld.Islands.Floating Island.Island.Portal.Spawn"
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
	end,
	DoubleClick = false,
})
local TeleportOuterSpace = TeleportsGroupBox:AddButton({
	Text = 'Teleport To Outer Space',
	Func = function()
		local args = {
			"Teleport",
			"Workspace.Worlds.The Overworld.Islands.Outer Space.Island.Portal.Spawn"
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
	end,
	DoubleClick = false,
})
local TeleportTwilight = TeleportsGroupBox:AddButton({
	Text = 'Teleport To Twilight',
	Func = function()
		local args = {
			"Teleport",
			"Workspace.Worlds.The Overworld.Islands.Twilight.Island.Portal.Spawn"
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
	end,
	DoubleClick = false,
})
local TeleportTheVoid = TeleportsGroupBox:AddButton({
	Text = 'Teleport To The Void',
	Func = function()
		local args = {
			"Teleport",
			"Workspace.Worlds.The Overworld.Islands.The Void.Island.Portal.Spawn"
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
	end,
	DoubleClick = false,
})
local TeleportZen = TeleportsGroupBox:AddButton({
	Text = 'Teleport To Zen',
	Func = function()
		local args = {
			"Teleport",
			"Workspace.Worlds.The Overworld.Islands.Zen.Island.Portal.Spawn"
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
	end,
	DoubleClick = false,
})

local MenuGroupBox = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroupBox:AddButton('Unload', function() GithubSource:Unload() end)
