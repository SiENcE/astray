Astray
======

Astray is a lua based maze, room and dungeon generation library for dungeon crawlers and rougelike video games.

<p align="center">
 <a href="https://raw.githubusercontent.com/SiENcE/astray/master/sample.png">
  <img border="0" src="https://raw.githubusercontent.com/SiENcE/astray/master/sample.png">
 </a>
</p>

Quick Look
==========
    local astray = require('astray')

    local generator = astray.Astray:new( 25, 25, 30, 70, 80, astray.RoomGenerator:new(8, 3, 6, 3, 6) )
    
	local dungeon = generator:Generate()
    
	local tiles = generator:CellToTiles( dungeon )
	
    for y = 0, #tiles[1] do
        local line = ''
		for x = 0, #tiles do
			line = line .. tiles[x][y]
		end
		print(line)
	end

Documentation
=============

See the [github wiki page](https://github.com/SiENcE/Astray/wiki) for examples & documentation.

Installation
============

Just copy the astray folder wherever you want it (for example on a lib/ folder). Then write this in any Lua file where you want to use it:

    local astray = require('lib/astray')

Specs
=====

This work mainly based on the following ideas:
  * http://dirkkok.wordpress.com/2007/11/21/generating-random-dungeons-part-1/
  * http://inkwellideas.com/advice/random-dungeon-generators-reviewed/
  * http://thomasbowker.com/2013/08/02/generating-a-dungeon/
  * http://www.myth-weavers.com/generate_dungeon.php

License
=======

Astray is distributed under the zlib/libpng License (http://opensource.org/licenses/Zlib)
