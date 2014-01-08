local PATH = (...):match("(.-)[^%.]+$")

local class = require(PATH .. 'MiddleClass')

-- Class
local Point = class("Point")

function Point:initialize( x, y )
	self.X = x
	self.Y = y
end

return Point
