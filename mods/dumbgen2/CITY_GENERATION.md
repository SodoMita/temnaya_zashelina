# City Generation System

## Overview
The city generation system creates procedural urban environments in designated "city" zones. It generates streets, sidewalks, buildings of varying heights and styles, parks, and street lamps using deterministic hash-based algorithms.

## Architecture

### Integration with Zone System
- Registered as "city" zone type via `temz_zones.register_generator()`
- Generates in Y range: -20 to 50
- Automatically assigned to zones based on zone weights in settings
- Fully integrated with dumbgen2 orchestrator and VoxelManip

### Generation Pipeline
1. **Zone Detection**: Orchestrator calls city generator for city-type zones
2. **Terrain Clearing**: Fill underground with stone, clear above ground
3. **Block Grid**: Divide zone into 40×40 node blocks
4. **Street Network**: Generate 8-node-wide streets in grid pattern
5. **Building Placement**: Hash-based building generation in plots
6. **Decoration**: Add sidewalks, street lamps, parks

## City Layout

### Block Structure
```
┌────────────────────────────────────┐
│  Street (8 nodes)                  │
├────────────────────────────────────┤
│                                    │
│    Building Plot (32×32 nodes)    │
│                                    │
│                                    │
└────────────────────────────────────┘
```

- **BLOCK_SIZE**: 40 nodes (building plot + street)
- **STREET_WIDTH**: 8 nodes
- **Plot Size**: 32×32 nodes (BLOCK_SIZE - STREET_WIDTH)

### Streets
- 8 nodes wide grid layout
- Asphalt road surface (4-6 nodes wide in center)
- Concrete sidewalks (2 nodes on each edge)
- Street lamps every 12 nodes on sidewalks
  - 4-node tall concrete pole
  - Glowing lamp block on top (light_source=14)

### Buildings
- **Sizes**: 10-28 nodes (randomly determined per block)
- **Heights**: 8-30 nodes tall (hash-based variation)
- **Styles**: 2 material types
  - Beton (gray concrete panels, modern)
  - White Bricks (clean white brick, traditional)
- **Features**:
  - Hollow interiors (filled with air)
  - Glass windows on walls (not corners)
  - Window pattern: every 4 floors
  - Flat roofs with thin slabs (concrete or gravel)
  - Centered in plot with small random offset

### Parks
- 15% of blocks are parks instead of buildings
- Grass ground cover
- Scattered trees (5% density)
- Open green spaces for variety

## Nodes Added

### Street/Infrastructure
- `uliza:asphalt` - Dark road surface
- `uliza:sidewalk` - Gray concrete walkways
- `uliza:street_lamp` - Glowing yellow lamp (light_source=14)

### Building Materials
- `constructions:beton` - Gray concrete panels (from constructions mod)
- `constructions:white_bricks2` - White brick blocks (from constructions mod)
- `uliza:framed_glass` - Windows (from existing uliza mod)
- `uliza:roof_slab_concrete` - Thin concrete roof slab (1/8 block height)
- `uliza:roof_slab_gravel` - Thin gravel roof slab (1/8 block height)

### Landscape
- `uliza:ground` - Base terrain (existing)
- `uliza:tree1` - Bare tree model (existing)

## Hash-Based Generation

All randomness is deterministic based on position and zone seed:

```lua
local function hash_pos(x, z, seed)
    local h = seed
    h = (h + x * 374761393) % 2147483647
    h = (h + z * 668265263) % 2147483647
    h = (h * 1664525 + 1013904223) % 2147483647
    return h
end
```

### Deterministic Features
- Building size: `hash_pos(block_x, block_z, seed)`
- Building height: Same hash, different modulo
- Building style: Hash division for material type
- Park placement: `hash_pos(block_x * 7, block_z * 11, seed + offset)`
- Tree placement: `hash_pos(x, z, seed + 7777)`

This ensures:
- Same zone always generates identically
- Changes propagate consistently
- No save data needed
- Chunks can be generated in any order

## Configuration

### Tunable Constants (city.lua)
```lua
BLOCK_SIZE = 40          -- City block size
STREET_WIDTH = 8         -- Street width
SIDEWALK_WIDTH = 2       -- Sidewalk width per side
BUILDING_MIN = 10        -- Min building size
BUILDING_MAX = 28        -- Max building size
BUILDING_HEIGHT_MIN = 8  -- Min building height
BUILDING_HEIGHT_MAX = 30 -- Max building height
LAMP_SPACING = 12        -- Distance between lamps
```

### Zone Weight Settings
In `minetest.conf` or as setting:
```
temz.zone_weights = city:1,labyrinth:1,factory:1
```

Adjust the weight to control city zone frequency.

## Testing

### Commands
```
/temz_zone_here          # Show current zone type
/temz_tp_zone <zx> <zz>  # Teleport to zone center
```

### Verification Checklist
- [ ] City zones generate (not empty/plain)
- [ ] Street grid is regular and aligned
- [ ] Buildings vary in size and height
- [ ] Buildings have different materials
- [ ] Glass windows appear on walls
- [ ] Roofs are properly placed
- [ ] Street lamps illuminate streets
- [ ] Parks appear occasionally
- [ ] Trees spawn in parks
- [ ] No gaps or holes in streets
- [ ] Underground is filled with stone

## Integration with Existing Systems

### Disabled Systems in City Zones
- `whimsi_utils` box generation (skipped for city zones)
- `dumbgen2` universal floor (overridden by city terrain)
- Default decorations/ores (city zones have custom deco)

### Compatible with
- Zone management system (temz_zones)
- VoxelManip-based orchestrator
- Labyrinth and factory zones (no conflicts)
- Ability/achievement systems (not affected)

## Future Enhancements

### Potential Additions
- **Building Interiors**: Floors, staircases, rooms
- **Building Variants**: Skyscrapers, shops, apartments
- **Road Decorations**: Traffic signs, benches, trash cans
- **Underground**: Sewers, subway tunnels
- **Parks**: Paths, fountains, sculptures
- **Lighting**: Building interior lights, neon signs
- **Density Zones**: Downtown (tall) vs suburbs (short)
- **Special Buildings**: City hall, church, station
- **Rooftop Features**: Antennas, gardens, helipads

### Code Improvements
- Extract building generation to separate function
- Add building "blueprints" for special structures
- Configurable building density
- Multi-story interior generation
- Door placement on buildings
- Connection to labyrinth/factory zones

## Technical Notes

### Performance
- VoxelManip ensures fast bulk generation
- No iterative algorithms (all hash-based lookups)
- Chunk-independent (no cross-chunk dependencies)
- Content IDs cached on first use

### Coordinate Systems
- **World coords**: Absolute Minetest position
- **Zone coords**: Which 501×501 zone (zx, zz)
- **Relative coords**: Position within zone (rel_x, rel_z)
- **Block coords**: Which city block within zone
- **In-block coords**: Position within 40×40 block

### Dependencies
- `uliza` mod (provides street nodes, glass, ground, trees)
- `constructions` mod (provides beton and white bricks for buildings)
- `temz_zones` (zone management)
- `default` mod (stone, sounds)
- `dumbgen2` (orchestration)

## Files Modified/Created

### New Files
- `mods/dumbgen2/city.lua` - City generator implementation
- `mods/dumbgen2/CITY_GENERATION.md` - This documentation

### Modified Files
- `mods/blocks/uliza/init.lua` - Added street nodes (asphalt, sidewalk, lamp) and thin roof slabs
- `mods/blocks/whimsi_utils/init.lua` - Skip city zones
- `mods/dumbgen2/init.lua` - Load city module

### Unchanged (Compatible)
- `mods/dumbgen2/zones.lua` - Zone management
- `mods/dumbgen2/orchestrator.lua` - Generation orchestrator
- `mods/labyrinth/generation.lua` - Labyrinth gen
- `mods/factory/generation.lua` - Factory gen

---

**Status**: Core implementation complete  
**Last Updated**: 2025-11-03  
**Testing**: Ready for in-game testing
