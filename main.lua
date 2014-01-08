--[[
Copyright (c) <''2014''> <''Florian Fischer''>
]]--

local astray = require('astray')

function drawdungeon(tiles, width, height)
    for y = 0, height do
        local line = ''
		for x = 0, width do
			line = line .. tiles[x][y]
		end
		print(line)
	end
end

function love.load()
	print('Astay Sample')
--	local generator = astray.Astray:new( 25, 25, 30, 70, 80, astray.RoomGenerator:new(8, 3, 6, 3, 6) )
--	local generator = astray.Astray:new( 5, 5, 1, 15, 5, astray.RoomGenerator:new(1, 1, 2, 1, 2) )
	local generator = astray.Astray:new( 4, 4, 5, 25, 90, astray.RoomGenerator:new(1, 2, 2, 2, 2) )
	local dungeon = generator:Generate()
	local tiles = generator:CellToTiles(dungeon, {Wall='²', Empty=' ', DoorN='-', DoorS='-', DoorE='|', DoorW='|'} )
	print("Mazesize=", #tiles+1, #tiles[1]+1 )
	drawdungeon(tiles, #tiles, #tiles[1] )
end

function love.draw()
end

function love.update(dt)
end
