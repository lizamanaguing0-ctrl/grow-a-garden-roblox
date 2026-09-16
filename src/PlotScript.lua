-- PlotScript.lua
-- Place this script inside each garden plot part in Roblox Studio
-- This script handles the seed planting interaction for individual plots

local PlantingSystem = require(game.ServerScriptService:WaitForChild("PlantingSystem"))

local plot = script.Parent
local debounce = false

-- Initialize plot attributes
if not plot:GetAttribute("Occupied") then
	plot:SetAttribute("Occupied", false)
	plot:SetAttribute("PlantType", nil)
	plot:SetAttribute("ReadyToHarvest", false)
end

-- Make the plot clickable/touchable
plot.CanCollide = true
plot.TopSurface = Enum.SurfaceType.Smooth
plot.BottomSurface = Enum.SurfaceType.Smooth

-- Function to plant a seed when player touches the plot
local function onPlotTouched(hit)
	if debounce then return end
	
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	debounce = true
	task.wait(1) -- Debounce to prevent multiple plants
	debounce = false
	
	-- Check if plot is empty
	if plot:GetAttribute("Occupied") then
		print("Plot is already occupied!")
		return
	end
	
	-- Default plant to Tomato (you can change this)
	local plantType = "Tomato"
	
	-- Plant the seed
	local success = PlantingSystem:plantSeed(plot, plantType)
	
	if success then
		-- Optional: Change plot appearance
		plot.Color = Color3.fromRGB(139, 90, 43) -- Darker brown for planted plot
		plot.TopSurface = Enum.SurfaceType.Smooth
	end
end

-- Connect touch event
plot.Touched:Connect(onPlotTouched)

-- Optional: Add a click detection using ClickDetector for more reliable interaction
local clickDetector = Instance.new("ClickDetector")
clickDetector.Parent = plot
clickDetector.MaxActivationDistance = 20

clickDetector.MouseClick:Connect(function(player)
	if plot:GetAttribute("Occupied") then
		print(player.Name .. " - Plot is already occupied!")
		return
	end
	
	-- Plant the seed on click
	local plantType = "Tomato"
	local success = PlantingSystem:plantSeed(plot, plantType)
	
	if success then
		plot.Color = Color3.fromRGB(139, 90, 43)
	end
end)

print("Plot script loaded for: " .. plot.Name)
