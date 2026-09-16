-- PlotScript.lua (FIXED - SIMPLE VERSION)
-- Place this script inside each garden plot part

local PlantingSystem = require(game.ServerScriptService:WaitForChild("PlantingSystem"))
local plot = script.Parent
local debounce = false

-- Initialize plot
plot:SetAttribute("Occupied", false)

-- When player clicks the plot
local clickDetector = Instance.new("ClickDetector")
clickDetector.MaxActivationDistance = 50
clickDetector.Parent = plot

clickDetector.MouseClick:Connect(function(player)
	if debounce then return end
	debounce = true
	
	-- Check if plot already has a plant
	if plot:GetAttribute("Occupied") then
		print("Plot already has a plant!")
		debounce = false
		return
	end
	
	-- Plant a Tomato
	PlantingSystem:plantSeed(plot, "Tomato")
	
	debounce = false
	task.wait(0.5)
end)

print("✓ Plot script ready! Click the plot to plant.")
