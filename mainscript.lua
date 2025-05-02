--██████╗░██╗░█████╗░███████╗  ██╗░░██╗██╗░░░██╗██████╗░
--██╔══██╗██║██╔══██╗██╔════╝  ██║░░██║██║░░░██║██╔══██╗
--██████╔╝██║██║░░╚═╝█████╗░░  ███████║██║░░░██║██████╦╝
--██╔══██╗██║██║░░██╗██╔══╝░░  ██╔══██║██║░░░██║██╔══██╗
--██║░░██║██║╚█████╔╝███████╗  ██║░░██║╚██████╔╝██████╦╝
--╚═╝░░╚═╝╚═╝░╚════╝░╚══════╝  ╚═╝░░╚═╝░╚═════╝░╚═════╝░

--//Check Game ID
if game.PlaceId ~= 85896571713843 then return end

--//Configuration Variables
local AutoBubble = false
local AutoBubbleDelay = 0
local AutoCollectCollectibles = false
local AutoCollectPickups = false
local AutoCollectPlaytimeRewards = false
local SelectedEgg = "--"
local AutoOpenEggs = false

--//RobloxServices
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Variables
local RenderedFolder = game.Workspace:WaitForChild("Rendered")
local WorldMap = game.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("WorldMap")
local WheelSpin = game.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("WheelSpin")
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

--//Startup
RefreshEggList()

--//Dependencies
local GithubRepository = 'https://raw.githubusercontent.com/ZH-KQ/roice/refs/heads/main/'
local GithubSource = loadstring(game:HttpGet(GithubRepository .. 'source.lua'))()
local ThemeManager = loadstring(game:HttpGet(GithubRepository .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(GithubRepository .. 'addons/SaveManager.lua'))()

--//WindowCreation
local Window = GithubSource:CreateWindow({
	-- Set Center to true if you want the menu to appear in the center
	-- Set AutoShow to true if you want the menu to appear when it is created
	-- Position and Size are also valid options here
	-- but you do not need to define them unless you are changing them :)
	Title = 'BGSI Rice Hub made by Ricee [🍚]',
	Center = true,
	AutoShow = true,
	TabPadding = 8
})

--//TabCreation
local Tabs = {
	['Main'] = Window:AddTab('Main'),
	['UI Settings'] = Window:AddTab('UI Settings'),
}

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
local AutoCollectGroupBox = Tabs.Main:AddRightGroupbox('Auto Collect')
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
				local function CheckPickup(instance)
					if not AutoCollectPickups then return end
					if isUUID(instance.Name) then
						local args = { instance.Name }
						ReplicatedStorage
							:WaitForChild("Remotes")
							:WaitForChild("Pickups")
							:WaitForChild("CollectPickup")
							:FireServer(unpack(args))
						pcall(function()
							instance:Destroy()
						end)
					end
				end
				local function CheckChunkerFolder(ChunkerFolder)
					for _, Pickup in pairs(ChunkerFolder:GetChildren()) do
						CheckPickup(Pickup)
					end

					ChunkerFolder.ChildAdded:Connect(function(Pickup)
						CheckPickup(Pickup)
					end)
				end
				for _, Child in pairs(RenderedFolder:GetChildren()) do
					if Child.Name == "Chunker" then
						CheckChunkerFolder(Child)
					end
				end
				RenderedFolder.ChildAdded:Connect(function(Child)
					if Child.Name == "Chunker" then
						CheckChunkerFolder(Child)
					end
				end)
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
local AutoEggsGroupBox = Tabs.Main:AddLeftGroupbox('Auto Eggs')
AutoEggsGroupBox:AddDropdown('SelectedEgg', {
	Values = SelectableEggsCollection,
	Default = 1,
	Multi = false, -- Sets if multiple options could be pressed
	Text = 'Selected Egg',
	Callback = function(Value)
		SelectedEgg = Value
		local PickedOption = SelectedEgg
		local EggLocation = nil
		for _, folder in ipairs(game.Workspace:WaitForChild("Rendered"):GetChildren()) do
			if folder:IsA("Folder") and folder.Name == "Chunker" then
				EggLocation = folder:FindFirstChild(PickedOption)
				if EggLocation then break end
			end
		end
		if EggLocation then
			print("Egg Location updated to: " .. EggLocation.Name)
			local EggPlate = EggLocation:FindFirstChild("Plate")
			local Character = game.Players.LocalPlayer.Character
			local Humanoid = Character and Character:FindFirstChild("Humanoid")
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			if not EggPlate or not HumanoidRootPart or not Humanoid then
				warn("Egg plate / HumanoidRootPart / Humanoid not found or doesn't exist!")
			else
				local targetPosition = EggPlate.Position + Vector3.new(0, 5, 0)
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
					local toTarget = targetPosition - HumanoidRootPart.Position
					local horizontal = Vector3.new(toTarget.X, 0, toTarget.Z)
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
					bodyVelocity.Velocity = Vector3.new(moveDirection.X, bodyVelocity.Velocity.Y, moveDirection.Z)
					if SelectedEgg ~= PickedOption then 
						reached = true
						return
					end
				end)
				local function stabilizeYVelocity()
					bodyVelocity.Velocity = Vector3.new(bodyVelocity.Velocity.X, 0, bodyVelocity.Velocity.Z)
				end
				RunService.RenderStepped:Connect(stabilizeYVelocity)
			end
		else
			print("Egg not found!")
		end
	end
})
local RefreshEggSelectionButton = AutoEggsGroupBox:AddButton({
	Text = 'Refresh Egg Selection',
	Func = function()
		local RefreshedEggList = RefreshEggList()
		if Options.SelectedEgg then
			Options.SelectedEgg:SetValues(RefreshedEggList)
			Options.SelectedEgg:SetValue("--")
			Options.SelectedEgg:CloseDropdown()
		else
			warn("SelectedEgg dropdown or RefreshDropdown method not found.")
		end
	end,
})
AutoEggsGroupBox:AddToggle('AutoOpenEggs', {
	Text = 'Auto Open Eggs',
	Default = false,
	Callback = function(Value)

	end
})
