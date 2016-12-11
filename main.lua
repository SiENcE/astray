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
	print('')
end

function love.load()
	print('Astay Sample\n')
	local symbols = {Wall='#', Empty=' ', DoorN='-', DoorS='-', DoorE='|', DoorW='|'}
	
	print('Automatic\n------------------------------------------\n')
	-- original setup
	--	width, height, changeDirectionModifier (1-30), sparsenessModifier (25-70), deadEndRemovalModifier (70-99)
	--																	rooms, minWidth, maxWidth, minHeight, maxHeight
	--local generator = astray.Astray:new( 25, 25, 30, 70, 50, astray.RoomGenerator:new(10,1,5,1,5) )
	local generator = astray.Astray:new( 20, 20, 25, 40, 80, astray.RoomGenerator:new(8, 2, 4, 2, 4) )
	local dungeon = generator:Generate()
	local tiles = generator:CellToTiles(dungeon, symbols )
	print("Mazesize=", #tiles+1, #tiles[1]+1 )
	drawdungeon(tiles, #tiles, #tiles[1] )

--[[
	print('\n-----------------------------------------------------\n')
	-- or manually each step
	print('Manually\n------------------------------------------\n')

--	local generator = astray.Astray:new( 25, 25, 30, 70, 80, astray.RoomGenerator:new(8, 3, 6, 3, 6) )
--	local generator = astray.Astray:new( 5, 5, 1, 15, 5, astray.RoomGenerator:new(1, 1, 2, 1, 2) )
	local generator = astray.Astray:new( 20, 10, 15, 70, 80, astray.RoomGenerator:new(4, 2, 6, 2, 6) )

	local dungeon = generator:GenerateDungeon()
	local tiles = generator:CellToTiles(dungeon, symbols )
	drawdungeon(tiles, #tiles, #tiles[1] )
	generator:GenerateSparsifyMaze(dungeon)
	local tiles = generator:CellToTiles(dungeon, symbols )
	drawdungeon(tiles, #tiles, #tiles[1] )
	generator:GenerateRemoveDeadEnds(dungeon)
	local tiles = generator:CellToTiles(dungeon, symbols )
	drawdungeon(tiles, #tiles, #tiles[1] )
	generator:GeneratePlaceRooms(dungeon)
	local tiles = generator:CellToTiles(dungeon, symbols )
	drawdungeon(tiles, #tiles, #tiles[1] )
	generator:GeneratePlaceDoors(dungeon)
	local tiles = generator:CellToTiles(dungeon, symbols )
	drawdungeon(tiles, #tiles, #tiles[1] )
]]--
end

function love.draw()
end

function love.update(dt)
end
