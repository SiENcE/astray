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
local Cell = require(PATH .. 'cell')
local Map = require(PATH .. 'map')

-- Class
local Room = class("Room", Map)

function Room:initialize( width, height )
--	print('Room:initialize')
	Map.initialize(self, width, height) -- invoking the superclass' initializer
end

function Room:InitializeRoomCells()
	for key,location in pairs( self:getCellLocations() ) do
		local cell = Cell:new()
		
		if (location.X == self.bounds.X) then
			cell.WestSide = SideType.Wall
		else
			cell.WestSide = SideType.Empty
		end
		
		if (location.X == self.bounds.Width - 1) then
			cell.EastSide = SideType.Wall
		else
			cell.EastSide = SideType.Empty
		end
		
		if (location.Y == self.bounds.Y) then
			cell.NorthSide = SideType.Wall
		else
			cell.NorthSide = SideType.Empty
		end
		
		if (location.Y == self.bounds.Height - 1) then
			cell.SouthSide = SideType.Wall
		else
			cell.SouthSide = SideType.Empty
		end

		self:setCell( location, cell )
	end
end

function Room:SetLocation( location )
	self.bounds = { X=location.X, Y=location.Y, Width=self.bounds.Width, Height=self.bounds.Height }
end

return Room
