local PATH = (...):match("(.-)[^%.]+$")

local class = require(PATH .. 'MiddleClass')
local Util = require(PATH .. 'util')

-- Class
local DirectionPicker = class("DirectionPicker")

function DirectionPicker:initialize( previousDirection, changeDirectionModifier )
--	print('DirectionPicker:initialize')
	self.directionsPicked = {}
	
	self.previousDirection = previousDirection
	self.changeDirectionModifier = changeDirectionModifier
end

-- return DirectionType
function DirectionPicker:PickDifferentDirection()
--	print('DirectionPicker:PickDifferentDirection')

	local directionPicked = math.random(0,3)
	while (directionPicked == self.previousDirection) and (#self.directionsPicked < 3) do
		directionPicked = math.random(0,3)
	end

	return directionPicked
end

-- return DirectionType
function DirectionPicker:GetNextDirection()
--	print('DirectionPicker:GetNextDirection')
	if (not self:HasNextDirection() ) then
		print('No directions available')
		return nil
	end

	local directionPicked = nil
	local changeDir = self:MustChangeDirection()
	if changeDir then
		directionPicked = self:PickDifferentDirection()
	else
		directionPicked = self.previousDirection
	end
	while Util:tablecontains( self.directionsPicked, directionPicked) do
		local changeDir = self:MustChangeDirection()
		if changeDir then
			directionPicked = self:PickDifferentDirection()
		else
			directionPicked = self.previousDirection
		end
	end

	table.insert( self.directionsPicked, directionPicked)
--	print( "tablesize=", #self.directionsPicked )
	
	return directionPicked
end

------------------------------------------------------
-- helper functions
------------------------------------------------------
-- return boolean
function DirectionPicker:HasNextDirection()
--	print('DirectionPicker:HasNextDirection count=',#self.directionsPicked)
	return (#self.directionsPicked < 4)
end

-- return boolean
function DirectionPicker:MustChangeDirection()
	-- changeDirectionModifier of 100 will always change direction
	-- value of 0 will never change direction
--	print('DirectionPicker:MustChangeDirection count=', #self.directionsPicked, ' or=',self.changeDirectionModifier > math.random(0, 99))
	return ((#self.directionsPicked > 0) or (self.changeDirectionModifier > math.random(0, 99)))
end

return DirectionPicker
