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
local Room = require(PATH .. 'room')

-- Class
local RoomGenerator = class("RoomGenerator")

function RoomGenerator:initialize(noOfRoomsToPlace, minRoomWidth, maxRoomWidth, minRoomHeight, maxRoomHeight)
--	print('RoomGenerator:initialize')
	self.noOfRoomsToPlace = noOfRoomsToPlace or 10
	self.minRoomWidth = minRoomWidth or 1
	self.maxRoomWidth = maxRoomWidth or 6
	self.minRoomHeight = minRoomHeight or 1
	self.maxRoomHeight = maxRoomHeight or 6
end

-- TODO: Instance.Next
function RoomGenerator:CreateRoom()
	local room = Room:new( math.random(self.minRoomWidth, self.maxRoomWidth), math.random(self.minRoomHeight, self.maxRoomHeight) )

	room:InitializeRoomCells()
	return room
end

function RoomGenerator:PlaceRooms( dungeon )
	-- Loop for the amount of rooms to place
	for roomCounter = 0, self.noOfRoomsToPlace-1 do
		local room = self:CreateRoom()
		
		local bestRoomPlacementScore = MaxValue
		local bestRoomPlacementLocation = nil

		for key,currentRoomPlacementLocation in pairs( dungeon:CorridorCellLocations() ) do
			local currentRoomPlacementScore = self:CalculateRoomPlacementScore( currentRoomPlacementLocation, room, dungeon )

			if (currentRoomPlacementScore < bestRoomPlacementScore) then
				bestRoomPlacementScore = currentRoomPlacementScore
				bestRoomPlacementLocation = currentRoomPlacementLocation
			end
		end

		-- Create room at best room placement cell
		if bestRoomPlacementLocation ~= nil then
			self:PlaceRoom( bestRoomPlacementLocation, room, dungeon )
		end
	end
end

function RoomGenerator:CalculateRoomPlacementScore( location, room, dungeon )
	-- Check if the room at the given location will fit inside the bounds of the map
	if Util:rectbound( {X=location.X, Y=location.Y, Width=room:getWidth() + 1, Height=room:getHeight() + 1}, dungeon:getBounds() ) then
		local roomPlacementScore = 0

		-- Loop for each cell in the room
		for key,roomLocation in pairs( room:getCellLocations() ) do
			--Translate the room cell location to its location in the dungeon
			local dungeonLocation = Point:new(location.X + roomLocation.X, location.Y + roomLocation.Y);

			-- Add 1 point for each adjacent corridor to the cell
			if dungeon:AdjacentCellInDirectionIsCorridor(dungeonLocation, DirectionType.North) then roomPlacementScore = roomPlacementScore + 1 end
			if dungeon:AdjacentCellInDirectionIsCorridor(dungeonLocation, DirectionType.South) then roomPlacementScore = roomPlacementScore + 1 end
			if dungeon:AdjacentCellInDirectionIsCorridor(dungeonLocation, DirectionType.West) then roomPlacementScore = roomPlacementScore + 1 end
			if dungeon:AdjacentCellInDirectionIsCorridor(dungeonLocation, DirectionType.East) then roomPlacementScore = roomPlacementScore + 1 end

			-- Add 3 points if the cell overlaps an existing corridor
			if (dungeon:getCell(dungeonLocation):getIsCorridor()) then roomPlacementScore = roomPlacementScore + 3 end

			-- Add 100 points if the cell overlaps any existing room cells
			for key,dungeonRoom in pairs(dungeon.rooms) do
				if Util:rectbound( dungeonLocation, dungeonRoom:getBounds() ) then
					roomPlacementScore = roomPlacementScore + 100
				end
			end
		end
		
		return roomPlacementScore
	else
		return MaxValue
	end
end

function RoomGenerator:PlaceRoom( location, room, dungeon )
	-- Offset the room origin to the new location
	room:SetLocation(location)

	-- Loop for each cell in the room
	for key,roomLocation in pairs( room:getCellLocations() ) do
		-- Translate the room cell location to its location in the dungeon
		local dungeonLocation = Point:new(location.X + roomLocation.X, location.Y + roomLocation.Y)

		dungeon:getCell(dungeonLocation):setNorthSide( room:getCell(roomLocation):getNorthSide() )
		dungeon:getCell(dungeonLocation):setSouthSide( room:getCell(roomLocation):getSouthSide() )
		dungeon:getCell(dungeonLocation):setWestSide( room:getCell(roomLocation):getWestSide() )
		dungeon:getCell(dungeonLocation):setEastSide( room:getCell(roomLocation):getEastSide() )

		-- Create room walls on map (either side of the wall)
		if (roomLocation.X == 0) and (dungeon:HasAdjacentCellInDirection(dungeonLocation, DirectionType.West)) then
			dungeon:CreateWall( dungeonLocation, DirectionType.West )
		end
		if (roomLocation.X == room:getWidth() - 1) and (dungeon:HasAdjacentCellInDirection(dungeonLocation, DirectionType.East)) then
			dungeon:CreateWall( dungeonLocation, DirectionType.East )
		end
		if (roomLocation.Y == 0) and (dungeon:HasAdjacentCellInDirection(dungeonLocation, DirectionType.North)) then
			dungeon:CreateWall( dungeonLocation, DirectionType.North )
		end
		if (roomLocation.Y == room:getHeight() - 1) and (dungeon:HasAdjacentCellInDirection(dungeonLocation, DirectionType.South)) then
			dungeon:CreateWall( dungeonLocation, DirectionType.South )
		end
	end

	dungeon:AddRoom(room)
end

-- TODO: check if Door has adjancent Walls beside!
function RoomGenerator:PlaceDoors( dungeon )
	for key,room in pairs(dungeon.rooms) do
		local hasNorthDoor = false
		local hasSouthDoor = false
		local hasWestDoor = false
		local hasEastDoor = false
		
		for key,cellLocation in pairs( room:getCellLocations() ) do
			-- Translate the room cell location to its location in the dungeon
			local dungeonLocation = Point:new(room:getBounds().X + cellLocation.X, room:getBounds().Y + cellLocation.Y)

			-- Check if we are on the west boundary of our room
			-- and if there is a corridor to the west
			if (cellLocation.X == 0) and
				(dungeon:AdjacentCellInDirectionIsCorridor(dungeonLocation, DirectionType.West)) and
				(not hasWestDoor) then
--	print('try-door at=', dungeonLocation.X*2+1, dungeonLocation.Y*2+1)
	-- check all adjacentCells for walls!!!
--	local targetN = dungeon:GetTargetLocation(dungeonLocation, DirectionType.North)
--	local targetS = dungeon:GetTargetLocation(dungeonLocation, DirectionType.South)
--	local targetE = dungeon:GetTargetLocation(dungeonLocation, DirectionType.East)
--	local targetW = dungeon:GetTargetLocation(dungeonLocation, DirectionType.West)
--	if targetN and targetS and targetE and targetW then
--		if dungeon:getCell(targetN):getWallCount()==4 and
--		   dungeon:getCell(targetS):getWallCount()==4 and
--		   dungeon:getCell(targetE):getWallCount()==4 and
--		   dungeon:getCell(targetW):getWallCount()==4 then
--					print('West-Door =',dungeonLocation.X*2+1, dungeonLocation.Y*2+1)
					dungeon:CreateDoor(dungeonLocation, DirectionType.West)
					hasWestDoor = true
--		end
--	end
			end

			-- Check if we are on the east boundary of our room
			-- and if there is a corridor to the east
			if (cellLocation.X == room:getWidth() - 1) and
				(dungeon:AdjacentCellInDirectionIsCorridor(dungeonLocation, DirectionType.East)) and
				(not hasEastDoor) then
--					print('East-Door =',dungeonLocation.X*2+1, dungeonLocation.Y*2+1)
					dungeon:CreateDoor(dungeonLocation, DirectionType.East)
					hasEastDoor = true
			end

			-- Check if we are on the north boundary of our room 
			-- and if there is a corridor to the north
			if (cellLocation.Y == 0) and
				(dungeon:AdjacentCellInDirectionIsCorridor(dungeonLocation, DirectionType.North)) and
				(not hasNorthDoor) then
--					print('North-Door =',dungeonLocation.X*2+1, dungeonLocation.Y*2+1)
					dungeon:CreateDoor(dungeonLocation, DirectionType.North)
					hasNorthDoor = true
			end

			-- Check if we are on the south boundary of our room 
			-- and if there is a corridor to the south
			if (cellLocation.Y == room:getHeight() - 1) and
				(dungeon:AdjacentCellInDirectionIsCorridor(dungeonLocation, DirectionType.South)) and
				(not hasSouthDoor) then
--					print('South-Door =',dungeonLocation.X*2+1, dungeonLocation.Y*2+1)
					dungeon:CreateDoor(dungeonLocation, DirectionType.South)
					hasSouthDoor = true
			end
			
		end
	end
end

------------------------------------------------------
-- helper functions
------------------------------------------------------
function RoomGenerator:getNoOfRoomsToPlace()
	return self.noOfRoomsToPlace
end
function RoomGenerator:setNoOfRoomsToPlace( noOfRoomsToPlace )
	self.noOfRoomsToPlace = noOfRoomsToPlace
end

function RoomGenerator:MinRoomWidth()
	return self.minRoomWidth
end
function RoomGenerator:MinRoomWidth( minRoomWidth )
	self.minRoomWidth = minRoomWidth
end

function RoomGenerator:MaxRoomWidth()
	return self.maxRoomWidth
end
function RoomGenerator:MaxRoomWidth( maxRoomWidth )
	self.maxRoomWidth = maxRoomWidth
end

function RoomGenerator:MinRoomHeight()
	return self.minRoomHeight
end
function RoomGenerator:MinRoomHeight( minRoomHeight )
	self.minRoomHeight = minRoomHeight
end

function RoomGenerator:MaxRoomHeight()
	return self.maxRoomHeight
end
function RoomGenerator:MaxRoomHeight( maxRoomHeight )
	self.maxRoomHeight = maxRoomHeight
end

return RoomGenerator
