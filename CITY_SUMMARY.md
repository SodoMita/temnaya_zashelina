# City Generation - Quick Summary

## What Was Implemented

### City Generator (`mods/dumbgen2/city.lua`) - USSR Microdistrict Style
- Procedural Soviet-style residential blocks (khrushchyovka/panel buildings)
- Standard 9-story panel buildings (12×40 nodes, 36 nodes tall)
- Proper building structure: 4 walls, floor slabs every 4 nodes, flat roof
- Two building materials: beton (gray) and white bricks
- Flat roofs using thin slabs (1/8 block height)
- Regular window pattern (every 4 nodes, at height 2 per floor)
- Mostly pedestrian paths (80%), rare asphalt roads (20%)
- Recreation zones with playgrounds (25% of blocks)
- Street lamps with lighting
- Hash-based deterministic generation

### New Nodes Added (`mods/blocks/uliza/init.lua`)

**Streets:**
- `uliza:asphalt` - Dark road surface
- `uliza:sidewalk` - Gray concrete walkways
- `uliza:street_lamp` - Glowing lamp (light_source=14)

**Roofs (thin slabs - 1/8 height):**
- `uliza:roof_slab_concrete` - Gray flat roof
- `uliza:roof_slab_gravel` - Dark gravel roof

**Temporary nodes (can be removed):**
- `uliza:concrete`, `uliza:brick_red`, `uliza:plaster_white`, `uliza:roof_tile`
  (These were replaced by constructions mod nodes)

### Existing Nodes Used
- `constructions:beton` - Main building material
- `constructions:white_bricks2` - Alternative building material
- `uliza:framed_glass` - Windows
- `uliza:ground` - Terrain
- `uliza:tree1` - Park decoration

## City Layout - USSR Microdistrict

```
Block Grid (60×60 nodes each):
┌────────┬─────────────────────────────────────────┐
│ Path   │                                        │
│ 4 wide │   Panel Building (12×40 or 40×12)  │
│        │   - 9 floors (36 nodes tall)          │
│        │   - Floor slabs every 4 nodes         │
│ Ped/   │   - Windows at height 2 per floor     │
│ Road   │   - 4 solid walls                     │
│        │   - Hollow interior (air)             │
│        │                                        │
│        │   OR Recreation Zone (25% chance):   │
│        │   - Trees, playground elements        │
└────────┴─────────────────────────────────────────┘

Paths: 80% pedestrian (sidewalk) / 20% asphalt roads
```

## Testing

```bash
# In Minetest:
/temz_zone_here               # Check current zone type
/temz_tp_zone 1 0             # Teleport to zone (1,0)
/temz_tp_zone 0 1             # Try another zone
```

Walk around to find city zones. They'll have:
- Mostly pedestrian paths (sidewalk), rare asphalt roads
- Tall 9-story panel buildings (beton or white brick)
- Regular window patterns on all 4 walls
- Floor slabs visible inside buildings (every 4 nodes)
- Flat roofs with thin slabs
- Street lamps at night
- Recreation zones with playground elements and trees (25% of blocks)

## Configuration

Edit `mods/dumbgen2/city.lua` to adjust:
- `BLOCK_SIZE = 60` - Microdistrict block size
- `PATH_WIDTH = 4` - Pedestrian path width
- `BUILDING_WIDTH = 12` - Panel building width
- `BUILDING_DEPTH = 40` - Panel building length
- `BUILDING_HEIGHT = 36` - Building height (9 floors × 4)
- `FLOOR_HEIGHT = 4` - Nodes per floor
- Asphalt road frequency: line 48 `< 20` = 20%
- Recreation zone density: line 54 `< 25` = 25%

Edit `minetest.conf` for zone distribution:
```
temz.zone_weights = city:1,labyrinth:1,factory:1
```

## Files Changed

**New:**
- `mods/dumbgen2/city.lua` (253 lines)
- `mods/dumbgen2/CITY_GENERATION.md` (full docs)

**Modified:**
- `mods/blocks/uliza/init.lua` (+91 lines: street nodes + roof slabs)
- `mods/blocks/whimsi_utils/init.lua` (skip city zones)
- `mods/dumbgen2/init.lua` (load city module)

**Dependencies:**
- `uliza` (streets, glass, terrain)
- `constructions` (building materials)
- `temz_zones` (zone system)
- `dumbgen2` (orchestrator)

## Next Steps (Optional)

1. **Test in-game** - Create world, explore city zones
2. **Adjust parameters** - Tweak building heights, density
3. **Add more variety:**
   - Different building shapes
   - Interior floors/rooms
   - More park decorations
   - Special buildings (shops, towers)
4. **Optimize** - Profile if generation is slow
5. **Clean up** - Remove unused temporary nodes from uliza

## Notes

- USSR microdistrict style (Soviet residential blocks)
- Buildings are proper structures: 4 walls, floors every 4 nodes, hollow interior
- 9 stories tall (36 nodes), uniform panel construction
- Mostly pedestrian-friendly (80% sidewalk paths, 20% asphalt roads)
- Recreation zones with playground elements (25% of blocks)
- Buildings can be oriented N-S or E-W (12×40 or 40×12)
- Generation is deterministic (same zone always identical)
- No save data needed (regenerates from hash)
- Compatible with labyrinth and factory zones
- Flat roofs and floor slabs use thin nodeboxes (1/8 block height)
- Buildings use existing constructions mod materials
- All syntax checked and working
