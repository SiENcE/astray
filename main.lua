--[[
Copyright (c) <''2024''> <''Florian Fischer''>
]]--

local astray = require('astray')

local symbols = {Wall='#', Empty=' ', DoorN='|', DoorS='|', DoorE='-', DoorW='-'}

function drawdungeon(tiles, startx, starty, width, height)
	-- we have to add +1 for the 0 rows
	print("Map size=", #tiles+1-startx, #tiles[1]+1-starty )

    for y = startx, height do
        local line = ''
		for x = starty, width do
			line = line .. tiles[y][x]
		end
		print(line)
	end
	print('')
end

function updatewalls(tiles, width, height)
	local block = false
    for y = 0, height do
		for x = 0, width do
			if tiles[x][y] == '#' then
				if block then
					tiles[x][y] = '#'
				else
					tiles[x][y] = 'O'
				end
			end
			block = not block
		end
	end
	return tiles
end

function fixTiles( tiles, width, height )
	local fixed_tiles = {}
	for y = 0, height do
		for x = 0, width do
			if not fixed_tiles[y+1] then fixed_tiles[y+1] = {} end
			fixed_tiles[y+1][x+1] = tiles[y][x]
		end
	end
	return fixed_tiles
end

print('Astay Sample\n')

print('Automatic\n------------------------------------------\n')

-- NOTE: This maze generator only accepts even number and can only generate uneven maps!
-- So when you input 40, 40 you get a -> 39,39 map.
local height, width = 40, 40

--	Function Header: Astray:new(width/2-1, height/2-1, changeDirectionModifier (1-30), sparsenessModifier (25-70), deadEndRemovalModifier (70-99) ) | RoomGenerator:new(rooms, minWidth, maxWidth, minHeight, maxHeight)
local generator = astray.Astray:new( height/2-1, width/2-1, 30, 70, 50, astray.RoomGenerator:new(4, 2, 4, 2, 4) )

-- original setup
--local generator = astray.Astray:new( 25, 25, 30, 70, 50, astray.RoomGenerator:new(10,1,5,1,5) )

local dungeon = generator:Generate()
--local tiles = generator:CellToTiles(dungeon, symbols)
local tiles = generator:CellToTiles(dungeon)
-- to alternate between two wall-types
updatewalls(tiles, #tiles, #tiles[1] )
-- draw on console
drawdungeon(tiles, 0, 0, #tiles, #tiles[1] )
-- fix array index to 1 (instead of 0)
local fixed_tiles = fixTiles( tiles, #tiles, #tiles[1] )
-- draw on console
drawdungeon(fixed_tiles, 1, 1, #fixed_tiles, #fixed_tiles[1] )
