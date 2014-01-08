--[[
Copyright (c) <''2014''> <''Florian Fischer''>

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source
   distribution.
]]--

-- Globals
DirectionType = { North = 0, South = 1, East = 2, West = 3 }
SideType = { Empty=1, Wall=2, Door=3 }
MaxValue = 65535

local PATH = (...):match("(.-)[^%.]+$")

local class = require(PATH .. 'MiddleClass')
local Point = require(PATH .. 'point')
local RoomGenerator = require(PATH .. 'roomgenerator')
local Dungeon = require(PATH .. 'dungeon')
local DirectionPicker = require(PATH .. 'directionpicker')

-- Class
local Astray = class("Astray")

function Astray:initialize( width, height, changeDirectionModifier, sparsenessModifier, deadEndRemovalModifier, roomGenerator)
--	print('Astray:initialize')
	math.randomseed(os.time())
	math.random(); math.random(); math.random()
	
	self.width = width or 25
	self.height = height or 25
	self.changeDirectionModifier = changeDirectionModifier or 30
	self.sparsenessModifier = sparsenessModifier or 70
	self.deadEndRemovalModifier = deadEndRemovalModifier or 50
	self.roomGenerator = roomGenerator or RoomGenerator:new(10, 1, 5, 1, 5)
end

function Astray:Generate()
	local dungeon = Dungeon:new(self.width, self.height)
	dungeon:FlagAllCellsAsUnvisited()
	
	self:CreateDenseMaze(dungeon)
	self:SparsifyMaze(dungeon)
	self:RemoveDeadEnds(dungeon)

	self.roomGenerator:PlaceRooms(dungeon)
	self.roomGenerator:PlaceDoors(dungeon)

	return dungeon
end

function Astray:GenerateDungeon()
	local dungeon = Dungeon:new(self.width, self.height)
	dungeon:FlagAllCellsAsUnvisited()
	self:CreateDenseMaze(dungeon)
	return dungeon
end
function Astray:GenerateSparsifyMaze(dungeon)
	self:SparsifyMaze(dungeon)
end
function Astray:GenerateRemoveDeadEnds(dungeon)
	self:RemoveDeadEnds(dungeon)
end
function Astray:GeneratePlaceRooms(dungeon)
	self.roomGenerator:PlaceRooms(dungeon)
end
function Astray:GeneratePlaceDoors(dungeon)
	self.roomGenerator:PlaceDoors(dungeon)
end

function Astray:CreateDenseMaze( dungeon )
	local currentLocation = dungeon:PickRandomCellAndFlagItAsVisited()
	local previousDirection = DirectionType.North

	while (not dungeon:AllCellsAreVisited() ) do
		local directionPicker = DirectionPicker:new(previousDirection, self.changeDirectionModifier)
		local direction = directionPicker:GetNextDirection()
		
--		print(currentLocation.X, currentLocation.Y)
--		print("Map", not dungeon:HasAdjacentCellInDirection(currentLocation, direction))
--		print("Dungeon", dungeon:AdjacentCellInDirectionIsVisited(currentLocation, direction))
		
		while (not dungeon:HasAdjacentCellInDirection(currentLocation, direction)) or dungeon:AdjacentCellInDirectionIsVisited(currentLocation, direction) do
			if directionPicker:HasNextDirection() then
				direction = directionPicker:GetNextDirection()
			else
				currentLocation = dungeon:GetRandomVisitedCell(currentLocation) -- Get a new previously visited location
				directionPicker = DirectionPicker:new(previousDirection, self.changeDirectionModifier) -- Reset the direction picker
				direction = directionPicker:GetNextDirection() -- Get a new direction
			end
		end

		currentLocation = dungeon:CreateCorridor(currentLocation, direction)
		dungeon:FlagCellAsVisited(currentLocation)
		previousDirection = direction
	end
end

function Astray:SparsifyMaze( dungeon )
	-- Calculate the number of cells to remove as a percentage of the total number of cells in the dungeon
	local noOfDeadEndCellsToRemove = math.ceil((self.sparsenessModifier / 100) * (dungeon:getWidth() * dungeon:getHeight()))

--	print('noOfDeadEndCellsToRemove=',noOfDeadEndCellsToRemove)

	local i = 0
	local quit = false

	while (i < noOfDeadEndCellsToRemove) do
		local deadEndCellList = dungeon:DeadEndCellLocations() -- Get a new enumerator
		if #deadEndCellList < 2 then break end -- No new items exist so break out of loop
		
		for key,point in pairs(deadEndCellList) do
			local cell = dungeon:getCell(point)
			local direction = cell:CalculateDeadEndCorridorDirection()
--			print(i, point.X, point.Y, cell:getIsDeadEnd(), direction)
			
			dungeon:CreateWall( point, direction )
			dungeon:getCell(point):setIsCorridor(false)
			
			i=i+1
			if i >= noOfDeadEndCellsToRemove then quit=true break end
		end

		if quit then break end
	end
end

function Astray:RemoveDeadEnds( dungeon )
	local deadEndCellList = dungeon:DeadEndCellLocations()
	for key,deadEndLocation in pairs( deadEndCellList ) do
		if self:ShouldRemoveDeadend() then
			local currentLocation = deadEndLocation
--			print('removeDeadEnd = ',currentLocation.X, currentLocation.Y)
				
			repeat
				local directionPicker = DirectionPicker:new( dungeon:getCell(currentLocation):CalculateDeadEndCorridorDirection(), 100)
				local direction = directionPicker:GetNextDirection()
				
				while (not dungeon:HasAdjacentCellInDirection(currentLocation, direction)) do
					if directionPicker:HasNextDirection() then
						direction = directionPicker:GetNextDirection()
					else
						print("ERROR: This should not happen")
					end
				end
				-- Create a corridor in the selected direction
				currentLocation = dungeon:CreateCorridor(currentLocation, direction)
			until (not dungeon:getCell(currentLocation):getIsDeadEnd()) -- Stop when you intersect an existing corridor.

		end
	end
end

function Astray:ShouldRemoveDeadend()
	return math.random(1, 99) < self.deadEndRemovalModifier
end

function Astray:CellToTiles( dungeon, tiles )
	local tile = tiles
	if not tile then
		tile = {}
		tile.Wall = '²'
		tile.Empty = ' '
		tile.DoorN = '|'
		tile.DoorS = '|'
		tile.DoorE = '-'
		tile.DoorW = '-'
	end
	
	local expanded = {}
    for x = 0, dungeon:getWidth()*2 do
        expanded[x] = {}
        for y = 0, dungeon:getHeight()*2  do
			expanded[x][y] = tile.Wall
		end
	end
	
	local minPoint = nil
	local maxPoint = nil
	for key,room in pairs(dungeon.rooms) do
		-- Get the room min and max location in tile coordinates
		minPoint = Point:new(room:getBounds().X * 2 + 1, room:getBounds().Y * 2 + 1)
		maxPoint = Point:new( (room:getBounds().X+room:getBounds().Width) * 2, (room:getBounds().Y+room:getBounds().Height) * 2 )
		
--		print("Roomsize=", room:getBounds().Width, room:getBounds().Height)
--		print("Real Roomsize=", maxPoint.X-minPoint.X, maxPoint.Y-minPoint.Y)

		-- Fill the room in tile space with an empty value
		for i = minPoint.X, maxPoint.X-1 do
			for j = minPoint.Y, maxPoint.Y-1 do
				expanded[i][j] = tile.Empty
			end
		end
	end

	local target = nil
	for key,location in pairs( dungeon:CorridorCellLocations() ) do
		target = Point:new(location.X*2+1, location.Y*2+1)
		expanded[target.X][target.Y] = tile.Empty

		if dungeon:getCell(location):getNorthSide() == SideType.Empty then expanded[target.X][target.Y-1] = tile.Empty end
		if dungeon:getCell(location):getNorthSide() == SideType.Door then expanded[target.X][target.Y-1] = tile.DoorN end

		if dungeon:getCell(location):getSouthSide() == SideType.Empty then expanded[target.X][target.Y+1] = tile.Empty end
		if dungeon:getCell(location):getSouthSide() == SideType.Door then expanded[target.X][target.Y+1] = tile.DoorS end

		if dungeon:getCell(location):getEastSide() == SideType.Empty then expanded[target.X+1][target.Y] = tile.Empty end
		if dungeon:getCell(location):getEastSide() == SideType.Door then expanded[target.X+1][target.Y] = tile.DoorE end

		if dungeon:getCell(location):getWestSide() == SideType.Empty then expanded[target.X-1][target.Y] = tile.Empty end
		if dungeon:getCell(location):getWestSide() == SideType.Door then expanded[target.X-1][target.Y] = tile.DoorW end
	end
	return expanded
end

------------------------------------------------------
-- helper functions
------------------------------------------------------
function Astray:getWidth()
	return self.width
end
function Astray:setWidth( width )
	self.width = width
end

function Astray:getHeight()
	return self.height
end
function Astray:setHeight( height )
	self.height = height
end

function Astray:getChangeDirectionModifier()
	return self.changeDirectionModifier
end
function Astray:setChangeDirectionModifier( changeDirectionModifier )
	self.changeDirectionModifier = changeDirectionModifier
end

function Astray:getSparsenessModifier()
	return self.sparsenessModifier
end
function Astray:setSparsenessModifier( sparsenessModifier )
	self.sparsenessModifier = sparsenessModifier
end

function Astray:getDeadEndRemovalModifier()
	return self.deadEndRemovalModifier
end
function Astray:setDeadEndRemovalModifier( deadEndRemovalModifier )
	self.deadEndRemovalModifier = deadEndRemovalModifier
end

return Astray
