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

local PATH = (...):match("(.-)[^%.]+$")

local class = require(PATH .. 'MiddleClass')
local Util = require(PATH .. 'util')
local Point = require(PATH .. 'point')
local Map = require(PATH .. 'map')

-- Class
local Dungeon = class("Dungeon", Map)

function Dungeon:initialize( width, height )
--	print('Dungeon:initialize')
	Map.initialize(self, width, height) -- invoking the superclass' initializer

	self.visitedCells = {}
	self.rooms = {}
end

function Dungeon:AddRoom( room )
	table.insert(self.rooms, room )
end

function Dungeon:FlagAllCellsAsUnvisited()
	for key,location in pairs( self:getCellLocations() ) do
		self:getCell(location):setVisited(false)
	end
end

-- return point
-- TODO: proof the -1 and 0 !!!!!!!!!!!!!
function Dungeon:PickRandomCellAndFlagItAsVisited()
	local randomLocation = Point:new(math.random(0,self:getWidth() - 1), math.random(0,self:getHeight() - 1))
	self:FlagCellAsVisited(randomLocation)
	return randomLocation
end

-- return boolean
function Dungeon:AdjacentCellInDirectionIsVisited( location, direction )
	local target = self:GetTargetLocation(location, direction)
	
	if target == nil then
		return false
	end
	
	-- TODO optimize!!!
	if direction == DirectionType.North then
		return self:getCell(target):getVisited()
	elseif direction == DirectionType.West then
		return self:getCell(target):getVisited()
	elseif direction == DirectionType.South then
		return self:getCell(target):getVisited()
	elseif direction == DirectionType.East then
		return self:getCell(target):getVisited()
	else
		print('ERROR: InvalidOperationException (Dungeon:AdjacentCellInDirectionIsVisited)')
		return nil
	end
end

-- return boolean
function Dungeon:AdjacentCellInDirectionIsCorridor( location, direction )
	local target = self:GetTargetLocation(location, direction)

	if target == nil then
		return false
	end

	-- TODO optimize!!!
	if direction == DirectionType.North then
		return self:getCell(target):getIsCorridor()
	elseif direction == DirectionType.West then
		return self:getCell(target):getIsCorridor()
	elseif direction == DirectionType.South then
		return self:getCell(target):getIsCorridor()
	elseif direction == DirectionType.East then
		return self:getCell(target):getIsCorridor()
	else
		print('ERROR: InvalidOperationException (Dungeon:AdjacentCellInDirectionIsCorridor)')
		return false
	end
end

function Dungeon:FlagCellAsVisited( location )
	if not Util:rectbound(location, self:getBounds() ) then
		print('ERROR: Location is outside of Dungeon bounds')
	end

	if self:getCell(location):getVisited() then
		print('ERROR: Location is already visited')
	end

	self:getCell(location):setVisited(true)
	table.insert( self.visitedCells, location )
end

-- return point
function Dungeon:GetRandomVisitedCell( location )
	if (#self.visitedCells == 0) then
		print("ERROR: There are no visited cells to return.")
		return nil
	end

	local index = math.random(#self.visitedCells-1)

--	print("self.visitedCells", index)
--	print(self.visitedCells[index].X, location.X, self.visitedCells[index].Y, location.Y )

	-- Loop while the current cell is the visited cell
	while (self.visitedCells[index].X == location.X and self.visitedCells[index].Y == location.Y) do
		index = math.random(#self.visitedCells - 1)
--		print("self.visitedCells", index)
--		print(self.visitedCells[index].X, location.X, self.visitedCells[index].Y, location.Y )
	end
	
	return self.visitedCells[index]
end

-- return point
function Dungeon:CreateCorridor( location, direction )
--	print('Dungeon:CreateCorridor')
	local targetLocation = self:CreateSide(location, direction, SideType.Empty)
	
	self:getCell(location):setIsCorridor(true)	-- Set current location to corridor
	self:getCell(targetLocation):setIsCorridor(true) --Set target location to corridor
	
	return targetLocation
end


-- return point
function Dungeon:CreateWall( location, direction )
--	print('Dungeon:CreateWall')
	return self:CreateSide(location, direction, SideType.Wall)
end

-- return point
function Dungeon:CreateDoor( location, direction )
--	print('Dungeon:CreateDoor')
	return self:CreateSide(location, direction, SideType.Door)
end

-- return point
function Dungeon:CreateSide( location, direction, sideType )
--	print('Dungeon:CreateSide')
	local target = self:GetTargetLocation(location, direction)

	if (target == nil) then
		print('ERROR: ArgumentException("There is no adjacent cell in the given direction", "location")')
	end

	if direction == DirectionType.North then
		self:getCell(location):setNorthSide( sideType )
		self:getCell(target):setSouthSide( sideType )
	elseif direction == DirectionType.South then
		self:getCell(location):setSouthSide( sideType )
		self:getCell(target):setNorthSide( sideType )
	elseif direction == DirectionType.West then
		self:getCell(location):setWestSide( sideType )
		self:getCell(target):setEastSide( sideType )
	elseif direction == DirectionType.East then
		self:getCell(location):setEastSide( sideType )
		self:getCell(target):setWestSide( sideType )
	end

	return target
end

------------------------------------------------------
-- helper functions
------------------------------------------------------

-- return boolean
function Dungeon:AllCellsAreVisited()
--	print('Dungeon:AllCellsAreVisited', #self.visitedCells, self:getWidth() * self:getHeight())
	return #self.visitedCells == ( self:getWidth() * self:getHeight() )
end

-- IEnumerable<Point>
function Dungeon:DeadEndCellLocations()
--	print('Dungeon:DeadEndCellLocations')
	
	local deadEndpointList = {}
	for key,point in pairs( self:getCellLocations() ) do
		if self:getCell(point):getIsDeadEnd() then
--			print('point=',point.X,point.Y,'deadend=',self:getCell(point):getIsDeadEnd())
			table.insert(deadEndpointList, point)
		end
	end

	return deadEndpointList
end

function Dungeon:CorridorCellLocations()
--	print('Dungeon:CorridorCellLocations')
	
	local corridorPointList = {}
	for key,point in pairs( self:getCellLocations() ) do
		if self:getCell(point):getIsCorridor() then
--			print('point=',point.X,point.Y,'isCorridor=',self:getCell(point):getIsCorridor())
			table.insert(corridorPointList, point)
		end
	end

	return corridorPointList
end

return Dungeon
