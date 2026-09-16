-- PlantingSystem.lua (IMPROVED)
-- Handles planting seeds in garden plots

local PlantingSystem = {}

-- Plant data configuration
local PLANTS = {
	Tomato = {
		growthTime = 5, -- 5 seconds for testing (change to 30 for actual game)
		harvestValue = 10,
		displayName = "Tomato",
		color = Color3.fromRGB(255, 0, 0)
	},
	Carrot = {
		growthTime = 10,
		harvestValue = 15,
		displayName = "Carrot",
		color = Color3.fromRGB(255, 165, 0)
	},
	Sunflower = {
		growthTime = 15,
		harvestValue = 25,
		displayName = "Sunflower",
		color = Color3.fromRGB(255, 215, 0)
	},
	Pumpkin = {
		growthTime = 20,
		harvestValue = 50,
		displayName = "Pumpkin",
		color = Color3.fromRGB(255, 140, 0)
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
		warn("Plot is already occupied!")
		return false
	end
	
	local plantData = PLANTS[plantType]
	
	-- Mark plot as occupied
	plot:SetAttribute("Occupied", true)
	plot:SetAttribute("PlantType", plantType)
	plot:SetAttribute("PlantedTime", tick())
	plot:SetAttribute("GrowthTime", plantData.growthTime)
	
	-- Create visual representation of seed (LARGER and MORE VISIBLE)
	local seed = Instance.new("Part")
	seed.Name = "Seed_" .. plantType
	seed.Shape = Enum.PartType.Ball
	seed.Size = Vector3.new(0.8, 0.8, 0.8) -- Larger seed
	seed.Color = Color3.fromRGB(139, 69, 19) -- Brown color
	seed.CanCollide = false
	seed.TopSurface = Enum.SurfaceType.Smooth
	seed.BottomSurface = Enum.SurfaceType.Smooth
	
	-- Position seed on top of plot
	local plotCenter = plot.Position
	local plotTop = plot.Position.Y + (plot.Size.Y / 2)
	seed.Position = Vector3.new(plotCenter.X, plotTop + 0.5, plotCenter.Z)
	seed.Parent = plot
	
	-- Tag the seed so we can track it
	seed:SetAttribute("IsSeed", true)
	seed:SetAttribute("PlantType", plantType)
	
	print("✓ Planted " .. plantData.displayName .. " in plot. Growth time: " .. plantData.growthTime .. " seconds")
	
	-- Start growth process
	self:startGrowth(plot, seed, plantData)
	
	return true
end

-- Function to handle plant growth
function PlantingSystem:startGrowth(plot, seed, plantData)
	if not seed or not seed.Parent then return end
	
	local startTime = tick()
	local growthTime = plantData.growthTime
	local connection
	
	-- Loop to simulate growth
	connection = game:GetService("RunService").Heartbeat:Connect(function()
		if not seed or not seed.Parent or not plot or not plot.Parent then
			if connection then connection:Disconnect() end
			return
		end
		
		local elapsedTime = tick() - startTime
		local growthProgress = math.min(elapsedTime / growthTime, 1)
		
		if growthProgress >= 1 then
			-- Plant is fully grown
			self:completeGrowth(plot, seed, plantData)
			connection:Disconnect()
		else
			-- Update seed size during growth
			local newSize = 0.8 + (growthProgress * 1.5)
			seed.Size = Vector3.new(newSize, newSize, newSize)
			
			-- Change color as it grows (brown -> plant color)
			local r = 139 - (139 * growthProgress) + (plantData.color.R * 255 * growthProgress)
			local g = 69 + (131 * growthProgress)
			local b = 19 - (19 * growthProgress)
			
			seed.Color = Color3.fromRGB(
				math.floor(r),
				math.floor(g),
				math.floor(b)
			)
		end
	end)
end

-- Function to complete plant growth
function PlantingSystem:completeGrowth(plot, seed, plantData)
	if not seed or not seed.Parent then return end
	
	-- Change seed to plant model
	seed.Name = "Plant_" .. plantData.displayName
	seed.Shape = Enum.PartType.Block
	seed.Size = Vector3.new(1.2, 2, 1.2)
	seed.Color = plantData.color -- Use plant's natural color
	seed:SetAttribute("IsPlant", true)
	seed:SetAttribute("IsSeed", false)
	
	-- Update plot attribute
	plot:SetAttribute("ReadyToHarvest", true)
	
	print("✓ " .. plantData.displayName .. " is ready to harvest!")
	
	-- Add touch detection for harvesting (one-time only)
	local harvested = false
	seed.Touched:Connect(function(hit)
		if harvested then return end
		
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then
			harvested = true
			self:harvestPlant(plot, seed, plantData)
		end
	end)
end

-- Function to harvest a plant
function PlantingSystem:harvestPlant(plot, plant, plantData)
	if not plot:GetAttribute("ReadyToHarvest") then
		return
	end
	
	-- Award currency
	local harvestValue = plantData.harvestValue
	print("✓ Harvested " .. plantData.displayName .. " for " .. harvestValue .. " currency!")
	
	-- Remove the plant
	plant:Destroy()
	
	-- Reset plot
	plot:SetAttribute("Occupied", false)
	plot:SetAttribute("PlantType", nil)
	plot:SetAttribute("ReadyToHarvest", false)
	plot.Color = Color3.fromRGB(139, 105, 20) -- Back to original dirt color
	
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
