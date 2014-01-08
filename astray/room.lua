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
