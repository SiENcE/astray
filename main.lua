--[[
Copyright (c) <''2024''> <''Florian Fischer''>

Sample usage of the astray maze / dungeon generator.
Run with:  lua main.lua
]]--

local astray = require('astray')

------------------------------------------------------------------
-- helpers
------------------------------------------------------------------

-- Print a 0-indexed tiles[x][y] grid (as returned by CellToTiles) to stdout.
local function drawDungeon(tiles)
	local maxX = #tiles      -- last column index (x)
	local maxY = #tiles[0]   -- last row index (y)
	print(string.format("Map size = %d x %d", maxX + 1, maxY + 1))

	for y = 0, maxY do
		local line = {}
		for x = 0, maxX do
			line[x + 1] = tiles[x][y]
		end
		print(table.concat(line))
	end
	print('')
end

-- Recolour every second wall tile to `alt`, giving a checkerboard wall look.
local function alternateWalls(tiles, wall, alt)
	for x = 0, #tiles do
		for y = 0, #tiles[0] do
			if tiles[x][y] == wall and (x + y) % 2 == 1 then
				tiles[x][y] = alt
			end
		end
	end
end

-- Convert a 0-indexed tiles[x][y] grid to a 1-indexed grid[y][x] (row-major),
-- handy if you prefer Lua's usual 1-based arrays.
local function to1Indexed(tiles)
	local grid = {}
	for y = 0, #tiles[0] do
		grid[y + 1] = {}
		for x = 0, #tiles do
			grid[y + 1][x + 1] = tiles[x][y]
		end
	end
	return grid
end

local function header(title)
	print(title)
	print(string.rep('-', 42))
end

------------------------------------------------------------------
-- examples
------------------------------------------------------------------

-- Astray:new(width/2-1, height/2-1, changeDir(1-30), sparseness(25-70),
--            deadEndRemoval(50-99), roomGenerator [, seed])
-- RoomGenerator:new(rooms, minWidth, maxWidth, minHeight, maxHeight)

print('Astray Sample\n')

-- 1) Default tiles (UTF-8 box characters), natural odd size.
--    A maze is a cell+wall grid, so CellToTiles is always odd: cells*2 + 1.
header('1) Default tiles, natural 39x39')
do
	local gen = astray.Astray:new(19, 19, 30, 70, 50,
		astray.RoomGenerator:new(4, 2, 4, 2, 4))
	drawDungeon(gen:CellToTiles(gen:Generate()))
end

-- 2) Custom ASCII symbols, padded to an exact even size, alternating walls.
header('2) Custom symbols, exact 40x40, alternating walls')
do
	local symbols = {Wall='#', Empty=' ', DoorN='-', DoorS='-', DoorE='|', DoorW='|'}
	local width, height = 40, 40
	local gen = astray.Astray:new(width/2-1, height/2-1, 30, 70, 50,
		astray.RoomGenerator:new(4, 2, 4, 2, 4))
	-- pass width,height so the natural 39x39 grid is padded up to 40x40
	local tiles = gen:CellToTiles(gen:Generate(), symbols, width, height)
	alternateWalls(tiles, '#', 'O')
	drawDungeon(tiles)
end

-- 3) Non-square map (wider than tall): winding corridors, heavy dead-end removal.
header('3) Non-square 60x30')
do
	local width, height = 60, 30
	local gen = astray.Astray:new(width/2-1, height/2-1, 10, 50, 90,
		astray.RoomGenerator:new(6, 2, 5, 2, 4))
	drawDungeon(gen:CellToTiles(gen:Generate(), nil, width, height))
end

-- 4) Reproducible output: pass a seed to get the same dungeon every run.
header('4) Reproducible maps (fixed seed)')
do
	local function build(seed)
		local gen = astray.Astray:new(12, 12, 30, 70, 50,
			astray.RoomGenerator:new(3, 2, 3, 2, 3), seed)
		return to1Indexed(gen:CellToTiles(gen:Generate()))
	end

	local a, b = build(1234), build(1234)
	local identical = true
	for y = 1, #a do
		for x = 1, #a[y] do
			if a[y][x] ~= b[y][x] then identical = false end
		end
	end
	print('two builds with seed 1234 are identical: ' .. tostring(identical) .. '\n')
end

-- 5) Programmatic access: the dungeon is queryable data, not just ASCII art.
header('5) Inspecting the dungeon data')
do
	local gen = astray.Astray:new(15, 15, 30, 70, 50,
		astray.RoomGenerator:new(5, 2, 4, 2, 4))
	local dungeon = gen:Generate()

	print('rooms placed   : ' .. #dungeon.rooms)
	print('corridor cells : ' .. #dungeon:CorridorCellLocations())
	for i, room in ipairs(dungeon.rooms) do
		local b = room:getBounds()
		print(string.format('  room %d: x=%d y=%d w=%d h=%d', i, b.X, b.Y, b.Width, b.Height))
	end
	print('')
end
