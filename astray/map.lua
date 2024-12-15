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
local Cell = require(PATH .. 'cell')

-- Class
local Map = class("Map")

function Map:initialize( width, height )
    self.cells = {}
    self.bounds = { X=0, Y=0, Width=width, Height=height }
    self.cellLocations = {} -- Add cache

    -- Initialize cells and cache locations
    for x = 0, self.bounds.Width-1 do
        self.cells[x] = {}
        for y = 0, self.bounds.Height-1 do
            self.cells[x][y] = Cell:new()
            table.insert(self.cellLocations, Point:new(x,y))
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
		return location.Y > 0
	elseif direction == DirectionType.South then
		return location.Y < (self:getHeight() - 1)
	elseif direction == DirectionType.West then
		return location.X > 0
	elseif direction == DirectionType.East then
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
	return self.bounds
end

function Map:getCell( point )
	return self.cells[point.X][point.Y]
end
function Map:setCell( point, value )
	self.cells[point.X][point.Y] = value
end

function Map:getWidth()
	return self.bounds.Width
end
function Map:getHeight()
	return self.bounds.Height
end

function Map:getCellLocations()
    return self.cellLocations
end

return Map
