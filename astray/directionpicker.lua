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

-- Class
local DirectionPicker = class("DirectionPicker")

function DirectionPicker:initialize(previousDirection, changeDirectionModifier)
    -- Initialize all available directions
    self.availableDirections = {
        DirectionType.North,
        DirectionType.South,
        DirectionType.East,
        DirectionType.West
    }
    self.previousDirection = previousDirection
    self.changeDirectionModifier = changeDirectionModifier
    self.directionsPicked = {}
end

function DirectionPicker:PickDifferentDirection()
    -- Filter out previously picked directions and the current direction
    local validDirections = {}
    for _, dir in ipairs(self.availableDirections) do
        if dir ~= self.previousDirection and not Util:tablecontains(self.directionsPicked, dir) then
            table.insert(validDirections, dir)
        end
    end
    
    -- If no valid directions, return any unpicked direction
    if #validDirections == 0 then
        for _, dir in ipairs(self.availableDirections) do
            if not Util:tablecontains(self.directionsPicked, dir) then
                return dir
            end
        end
        -- If all directions are picked, return the previous direction as last resort
        return self.previousDirection
    end
    
    -- Return random valid direction
    return validDirections[math.random(1, #validDirections)]
end

function DirectionPicker:GetNextDirection()
    if not self:HasNextDirection() then
        return nil
    end

    local directionPicked
    if self:MustChangeDirection() then
        directionPicked = self:PickDifferentDirection()
    else
        directionPicked = self.previousDirection
    end

    table.insert(self.directionsPicked, directionPicked)
    return directionPicked
end

function DirectionPicker:HasNextDirection()
    return #self.directionsPicked < 4
end

function DirectionPicker:MustChangeDirection()
    return (#self.directionsPicked > 0) or (self.changeDirectionModifier > math.random(0, 99))
end

return DirectionPicker