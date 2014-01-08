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
local Util = class("Util")

-- option1: check if point is in rect bound
-- option2: check if bound is in rect bound
function Util:rectbound( bounds1, bounds2)
	if bounds1.Width and bounds1.Height then
		local inbound = false
		local x1,y1 = bounds1.X, bounds1.Y
		local width1, height1 = bounds1.Width, bounds1.Height
		local x2,y2 = bounds2.X, bounds2.Y
		local width2, height2 = bounds2.Width, bounds2.Height
		
		if x1 >= x2 and x1 <= x2+width2 and
		   x1+width1 <= x2+width2 and
		   y1 >= y2 and y1 <= y2+height2 and
		   y1+height1 <= y2+height2 then
			inbound = true
		end
		return inbound
	else
		local inbound = false
		local x,y = bounds1.X, bounds1.Y
		local x2 = bounds2.X
		local y2 = bounds2.Y
		local width2, height2 = bounds2.Width, bounds2.Height
		if x >= x2 and x <= x2+width2 and y >= y2 and y <= y2+height2 then
			inbound = true
		end
		return inbound
	end
end

function Util:tablecontains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

return Util:new()
