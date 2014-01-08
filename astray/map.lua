local PATH = (...):match("(.-)[^%.]+$")

local class = require(PATH .. 'MiddleClass')
local Util = require(PATH .. 'util')
local Point = require(PATH .. 'point')
local Cell = require(PATH .. 'cell')

-- Class
local Map = class("Map")

function Map:initialize( width, height )
--	print('Map:initialize', width, height)
	
	self.cells = {}
	self.bounds = { X=0, Y=0, Width=width, Height=height }

	-- Initialize the array of cells
    for x = 0, self.bounds.Width-1 do
        self.cells[x] = {}
        for y = 0, self.bounds.Height-1 do
			self.cells[x][y] = Cell:new()
		end
	end
end

function Map:HasAdjacentCellInDirection( location, direction)
	-- Check that the location falls within the bounds of the map
	if not Util:rectbound(location, self.bounds) then
		print('ERROR: Map:HasAdjacentCellInDirection: not rectbound!!')
		return false
	end

	-- Check if there is an adjacent cell in the direction
	if direction == DirectionType.North then
--		print("North", location.Y > 0)
		return location.Y > 0
	elseif direction == DirectionType.South then
--		print("South",location.Y < (self:getHeight() - 1))
		return location.Y < (self:getHeight() - 1)
	elseif direction == DirectionType.West then
--		print("West",location.X > 0)
		return location.X > 0
	elseif direction == DirectionType.East then
--		print("East",location.X < (self:getWidth() - 1))
		return location.X < (self:getWidth() - 1)
	else
		print('ERROR: Map:HasAdjacentCellInDirection')
		return false
	end
end

-- return point
function Map:GetTargetLocation( location, direction)
	if not self:HasAdjacentCellInDirection(location, direction) then return nil end

	if direction == DirectionType.North then
		return Point:new(location.X, location.Y - 1)
	elseif direction == DirectionType.West then
		return Point:new(location.X - 1, location.Y)
	elseif direction == DirectionType.South then
		return Point:new(location.X, location.Y + 1)
	elseif direction == DirectionType.East then
		return Point:new(location.X + 1, location.Y)
	else
		print('ERROR: InvalidOperationException (Map:GetTargetLocation)')
		return nil
	end
end

------------------------------------------------------
-- helper functions
------------------------------------------------------

function Map:getBounds()
--	print('Map:getBounds')
	return self.bounds
end

-- renamed functions!!
function Map:getCell( point )
--	print('Map:getCell', point.X, point.Y)
	return self.cells[point.X][point.Y]
end
function Map:setCell( point, value )
--	print('Map:setCell', point.X, point.Y, value)
	self.cells[point.X][point.Y] = value
end

function Map:getWidth()
--	print('Map:getWidth')
	return self.bounds.Width
end
function Map:getHeight()
--	print('Map:getHeight')
	return self.bounds.Height
end

-- TODO: optimizes...do it only once during table initialize!!!!
function Map:getCellLocations()
--	print('Map:getCellLocations')

	local pointlist = {}
    for x = 0, self:getWidth()-1 do
        for y = 0, self:getHeight()-1 do
			table.insert( pointlist, Point:new(x,y) )
		end
	end
	return pointlist
end

return Map
