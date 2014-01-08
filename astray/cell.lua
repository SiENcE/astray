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

-- Class
local Cell = class("Cell")

function Cell:initialize()
	self.eastSide = SideType.Wall
	self.northSide = SideType.Wall
	self.southSide = SideType.Wall
	self.westSide = SideType.Wall
	self.visited = false
	self.isCorridor = false
end

function Cell:CalculateDeadEndCorridorDirection()
	if (not self:getIsDeadEnd()) then print('ERROR: InvalidOperationException (Cell:CalculateDeadEndCorridorDirection): not getIsDeadEnd()') end

	if (self.northSide == SideType.Empty) then return DirectionType.North end
	if (self.southSide == SideType.Empty) then return DirectionType.South end
	if (self.westSide == SideType.Empty) then return DirectionType.West end
	if (self.eastSide == SideType.Empty) then return DirectionType.East end

	print('ERROR: InvalidOperationException (Cell:CalculateDeadEndCorridorDirection)')
end

------------------------------------------------------
-- helper functions
------------------------------------------------------
function Cell:getVisited()
	return self.visited
end
function Cell:setVisited( visited )
	self.visited = visited
end

function Cell:getNorthSide()
	return self.northSide
end
function Cell:setNorthSide( northSide )
	self.northSide = northSide
end

function Cell:getSouthSide()
	return self.southSide
end
function Cell:setSouthSide( southSide )
	self.southSide = southSide
end

function Cell:getEastSide()
	return self.eastSide
end
function Cell:setEastSide( eastSide )
	self.eastSide = eastSide
end

function Cell:getWestSide()
	return self.westSide
end
function Cell:setWestSide( westSide )
	self.westSide = westSide
end

function Cell:getIsDeadEnd()
--	print("Wallcount=", self:getWallCount() )
	return self:getWallCount() == 3
end

function Cell:getIsCorridor()
	return self.isCorridor
end
function Cell:setIsCorridor( isCorridor )
	self.isCorridor = isCorridor
end

function Cell:getWallCount()
	local wallCount = 0
	if (self.northSide == SideType.Wall) then wallCount=wallCount+1 end
	if (self.southSide == SideType.Wall) then wallCount=wallCount+1 end
	if (self.westSide == SideType.Wall) then wallCount=wallCount+1 end
	if (self.eastSide == SideType.Wall) then wallCount=wallCount+1 end
	return wallCount
end

return Cell
