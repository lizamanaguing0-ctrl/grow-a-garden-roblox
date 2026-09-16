-- PlantingSystem.lua
-- Handles planting seeds in garden plots

local PlantingSystem = {}

-- Plant data configuration
local PLANTS = {
	Tomato = {
		growthTime = 30, -- seconds
		harvestValue = 10,
		displayName = "Tomato"
	},
	Carrot = {
		growthTime = 45,
		harvestValue = 15,
		displayName = "Carrot"
	},
	Sunflower = {
		growthTime = 60,
		harvestValue = 25,
		displayName = "Sunflower"
	},
	Pumpkin = {
		growthTime = 90,
		harvestValue = 50,
		displayName = "Pumpkin"
	}
}

-- Function to plant a seed in a plot
function PlantingSystem:plantSeed(plot, plantType)
	-- Check if plot is valid
	if not plot then
		warn("Invalid plot provided")
		return false
	end
	
	-- Check if plant type exists
	if not PLANTS[plantType] then
		warn("Plant type '" .. plantType .. "' does not exist")
		return false
	end
	
	-- Check if plot is already occupied
	if plot:GetAttribute("Occupied") then
		warn("Plot is already occupied")
		return false
	end
	
	local plantData = PLANTS[plantType]
	
	-- Mark plot as occupied
	plot:SetAttribute("Occupied", true)
	plot:SetAttribute("PlantType", plantType)
	plot:SetAttribute("PlantedTime", tick())
	plot:SetAttribute("GrowthTime", plantData.growthTime)
	
	-- Create visual representation of seed
	local seed = Instance.new("Part")
	seed.Name = "Seed"
	seed.Shape = Enum.PartType.Ball
	seed.Size = Vector3.new(0.5, 0.5, 0.5)
	seed.Color = Color3.fromRGB(139, 69, 19) -- Brown color
	seed.CanCollide = false
	seed.CFrame = plot.CFrame + Vector3.new(0, 0.5, 0)
	seed.Parent = plot
	
	-- Tag the seed so we can track it
	seed:SetAttribute("IsSeed", true)
	
	print("Planted " .. plantData.displayName .. " in plot. Growth time: " .. plantData.growthTime .. " seconds")
	
	-- Start growth process
	self:startGrowth(plot, seed, plantData)
	
	return true
end

-- Function to handle plant growth
function PlantingSystem:startGrowth(plot, seed, plantData)
	local startTime = tick()
	local growthTime = plantData.growthTime
	
	-- Loop to simulate growth
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function()
		if not plot or not plot.Parent then
			connection:Disconnect()
			return
		end
		
		local elapsedTime = tick() - startTime
		local growthProgress = elapsedTime / growthTime
		
		if growthProgress >= 1 then
			-- Plant is fully grown
			self:completeGrowth(plot, seed, plantData)
			connection:Disconnect()
		else
			-- Update seed size during growth
			local newSize = 0.5 + (growthProgress * 1.5)
			seed.Size = Vector3.new(newSize, newSize, newSize)
			
			-- Change color as it grows (brown -> green)
			local greenAmount = growthProgress
			seed.Color = Color3.fromRGB(
				139 - (139 * greenAmount),
				69 + (131 * greenAmount),
				19
			)
		end
	end)
end

-- Function to complete plant growth
function PlantingSystem:completeGrowth(plot, seed, plantData)
	-- Change seed to plant model
	seed.Name = "Plant"
	seed.Shape = Enum.PartType.Block
	seed.Size = Vector3.new(1, 2, 1)
	seed.Color = Color3.fromRGB(34, 139, 34) -- Forest green
	seed:SetAttribute("IsPlant", true)
	seed:SetAttribute("IsSeed", false)
	
	-- Update plot attribute
	plot:SetAttribute("ReadyToHarvest", true)
	
	-- Add touch detection for harvesting
	local humanoidTouched = false
	seed.Touched:Connect(function(hit)
		if humanoidTouched then return end
		
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then
			humanoidTouched = true
			self:harvestPlant(plot, seed, plantData)
		end
	end)
	
	print(plantData.displayName .. " is ready to harvest!")
end

-- Function to harvest a plant
function PlantingSystem:harvestPlant(plot, plant, plantData)
	if not plot:GetAttribute("ReadyToHarvest") then
		return
	end
	
	-- Award currency (you can integrate with your currency system)
	local harvestValue = plantData.harvestValue
	print("Harvested " .. plantData.displayName .. " for " .. harvestValue .. " currency")
	
	-- Remove the plant
	plant:Destroy()
	
	-- Reset plot
	plot:SetAttribute("Occupied", false)
	plot:SetAttribute("PlantType", nil)
	plot:SetAttribute("ReadyToHarvest", false)
	
	-- You can add code here to award currency to the player
	-- Example: player.leaderstats.Currency.Value += harvestValue
	
	return harvestValue
end

-- Function to get plant information
function PlantingSystem:getPlantInfo(plantType)
	return PLANTS[plantType]
end

-- Function to get all available plants
function PlantingSystem:getAvailablePlants()
	return PLANTS
end

return PlantingSystem
