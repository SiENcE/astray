# Astray

[![License: Zlib](https://img.shields.io/badge/License-Zlib-brightgreen.svg)](https://opensource.org/licenses/Zlib)

Astray is a robust Lua library for procedural generation of mazes, rooms, and dungeons. It provides a flexible system for creating diverse layouts suitable for dungeon crawlers, roguelikes, and other games requiring procedural map generation.

<p align="center">
 <a href="https://raw.githubusercontent.com/SiENcE/astray/master/sample.png">
  <img border="0" src="https://raw.githubusercontent.com/SiENcE/astray/master/sample.png">
 </a>
</p>

## Features

- Procedural maze generation using modified depth-first search
- Customizable room placement and connection
- Configurable parameters for dungeon characteristics:
  - Corridor density and sparseness
  - Room size and quantity
  - Dead end frequency
  - Direction change probability
- ASCII map output with customizable tiles
- Support for different cell types (corridors, rooms, doors)

## Installation

1. Copy the Astray folder to your project:
```bash
git clone https://github.com/SiENcE/astray.git
```

2. Include the library in your Lua code:
```lua
local astray = require('astray')
```

## Quick Start

```lua
local astray = require('astray')

-- Initialize generator with desired parameters
-- Note: Astray generates uneven-sized maps (e.g., 39x39 from 40x40 input)
local height, width = 40, 40
local generator = astray.Astray:new(
    width/2-1,                -- Map width
    height/2-1,               -- Map height
    30,                       -- Change direction modifier (1-30)
    70,                       -- Sparseness modifier (25-70)
    50,                       -- Dead end removal modifier (50-99)
    astray.RoomGenerator:new( -- Room generator configuration
        4,                    -- Number of rooms
        2, 4,                -- Min/Max room width
        2, 4                 -- Min/Max room height
    )
)

-- Generate dungeon
local dungeon = generator:Generate()

-- Convert to ASCII tiles
local tiles = generator:CellToTiles(dungeon)

-- Print the dungeon
for y = 0, #tiles[1] do
    local line = ''
    for x = 0, #tiles do
        line = line .. tiles[x][y]
    end
    print(line)
end
```

## Configuration

### Astray Constructor Parameters

```lua
Astray:new(width, height, changeDirectionMod, sparsenessMod, deadEndRemovalMod, roomGenerator)
```

| Parameter | Range | Description |
|-----------|-------|-------------|
| width | > 0 | Width of the dungeon in even numbers (map will be uneven) |
| height | > 0 | Height of the dungeon in even numbers (map will be uneven) |
| changeDirectionMod | 1-30 | Higher values create more winding corridors |
| sparsenessMod | 25-70 | Higher values create more open layouts |
| deadEndRemovalMod | 50-99 | Higher values remove more dead ends |

### Room Generator Parameters

```lua
RoomGenerator:new(rooms, minWidth, maxWidth, minHeight, maxHeight)
```

| Parameter | Description |
|-----------|-------------|
| rooms | Number of rooms to generate |
| minWidth | Minimum room width |
| maxWidth | Maximum room width |
| minHeight | Minimum room height |
| maxHeight | Maximum room height |

## Customizing Tiles

You can customize the appearance of generated dungeons by providing a tile mapping:

```lua
local symbols = {
    Wall = '#',
    Empty = ' ',
    DoorN = '|',
    DoorS = '|',
    DoorE = '-',
    DoorW = '-'
}

local tiles = generator:CellToTiles(dungeon, symbols)
```

## Example Output

```
Map size=       39      39
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓                 ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓ ▓▓▓-▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓   |       ▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓       ▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓       ▓▓▓▓▓     ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓-▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓   ▓▓▓▓▓▓▓     ▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓ ▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓ |   |       ▓   ▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓   ▓▓▓▓▓▓▓▓▓ ▓ ▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓   ▓▓▓▓▓     ▓       ▓
▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓ ▓▓▓▓▓▓▓ ▓
▓   ▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓ ▓▓▓▓▓▓▓ ▓
▓ ▓-▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓ ▓▓▓▓▓▓▓ ▓
▓ |     ▓▓▓▓▓             ▓▓▓     ▓   ▓
▓ ▓     ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓ ▓▓▓
▓ ▓     ▓▓▓▓▓▓▓▓▓                 ▓   ▓
▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓
▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓
▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓
▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓         ▓
▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓
▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓         ▓▓▓▓▓▓▓▓▓
▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓ ▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓
▓   ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓ ▓▓▓▓▓▓▓ ▓▓▓▓▓   ▓
▓ ▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓ ▓▓▓▓▓▓▓ ▓▓▓▓▓ ▓ ▓
▓         ▓▓▓▓▓▓▓ ▓▓▓     ▓▓▓ ▓▓▓▓▓   ▓
▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓-▓▓▓▓▓▓▓ ▓▓▓ ▓▓▓▓▓ ▓▓▓
▓▓▓▓▓▓▓▓▓       |       | ▓▓▓ ▓▓▓▓▓   ▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓       ▓ ▓▓▓ ▓▓▓▓▓▓▓ ▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓       ▓ ▓▓▓ ▓▓▓▓▓▓▓ ▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓       ▓ ▓▓▓ ▓▓▓▓▓▓▓ ▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓       ▓ ▓▓▓         ▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓-▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓     ▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
```

## License

Distributed under the [zlib/libpng License](https://opensource.org/licenses/Zlib). See `LICENSE` for more information.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Acknowledgments

This work is based on various dungeon generation techniques and algorithms:
- [Dirkkok's Random Dungeon Generation](http://dirkkok.wordpress.com/2007/11/21/generating-random-dungeons-part-1/)
- [Myth-Weavers Dungeon Generator](http://www.myth-weavers.com/generate_dungeon.php)
- [Thomas Bowker's Dungeon Generation](http://thomasbowker.com/2013/08/02/generating-a-dungeon/)

## Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/SiENcE/astray).