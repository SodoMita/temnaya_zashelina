# Map Generation Implementation Plan

## Current Status ✅

### Completed
- ✅ **Zone System**: World divided into 501×501 node squares with deterministic type assignment
- ✅ **Universal Floor**: Y=-20 to Y=0 filled with stone/dirt mix, grass/uliza:ground surface at Y=0
- ✅ **Orchestrator**: VoxelManip-based generation that calls zone-specific generators
- ✅ **Mod Scaffolding**: labyrinth and factory mods with placeholders for all systems
- ✅ **Debug Tools**: `/temz_zone_here` and `/temz_tp_zone` commands

### What's Working Now
- Flat ground at Y=0 with appropriate surface material per zone type
- Zone boundaries enforced (501×501 squares)
- Spawn zone (0,0) generates as plain grass
- Adjacent zones have random types (city/labyrinth/factory)

## Next Priority: Structure Generation

### Implementation Order

#### 1. Labyrinth Generation (Priority: HIGH)
**File**: `mods/labyrinth/generation.lua`

**Algorithm**:
```
1. Generate at Y=0 to Y=20 (6-7 nodes tall rooms)
2. Use 501x501 zone footprint
3. Create cell grid:
   - Cell size: 12-16 nodes
   - Corridor width: 3-4 nodes
   - Wall thickness: 1 node
4. Build maze graph:
   - Create grid graph of cells
   - Generate spanning tree (ensures all connected)
   - Add random cycles (5-10% extra edges for loops)
5. Carve structure:
   - Fill entire volume with constructions:beton walls
   - Carve out rooms in cell centers
   - Carve corridors along graph edges
   - Place labyrinth:slide_door_closed at transitions
6. Special zones:
   - Reserve center 3x3 cells for tutorial/workshop
   - Place default:chest with basic items
   - Add signs with tutorial text
7. Ghost triggers:
   - 20% of corridor wall segments
   - Store slide direction in node metadata
```

**Content IDs needed**:
- `constructions:beton` (walls)
- `constructions:white_bricks2` (variant walls)
- `air` (carving)
- `labyrinth:slide_door_closed` (doorways)
- `labyrinth:ghost_trigger` (hidden in walls)
- `default:chest` (loot/workshops)

**Generation Steps**:
1. Initialize content IDs (lazy load in generate function)
2. Fill bounding box with wall material
3. Generate cell graph using deterministic RNG
4. Carve rooms and corridors
5. Place doors at thresholds
6. Defer chest/sign placement to deferred queue

---

#### 2. Factory Generation (Priority: HIGH)
**File**: `mods/factory/generation.lua`

**Algorithm**:
```
1. Generate at Y=-20 to Y=100 (tall multi-floor structure)
2. Use most of 501x501 footprint (inset margins ~10 nodes)
3. Vertical layers:
   - Floor every 8 nodes: Y=-16, -8, 0, 8, 16, 24...96
   - Total: ~15 floors
4. Per-floor layout:
   - Outer wall perimeter
   - Corridor grid 4-6 nodes wide
   - Room modules between corridors
   - Chess pattern floors (constructions:wb_tile1/bw_tile1)
5. Vertical shafts:
   - Central core shaft (10x10 nodes)
   - 4 corner shafts (5x5 nodes each)
   - Fill with factory:pipe nodes
   - Add default:ladder for climbing
6. Door placement by tier:
   - Tier 1: Outer corridor doors (floors 0-32)
   - Tier 2: Mid-level doors (floors 32-64)
   - Tier 3: Core access doors (floors 64+)
7. Key fragment distribution:
   - Spawn chests with fragments
   - T1: 5-7 fragments on floors 0-16
   - T2: 8-10 fragments on floors 16-48
   - T3: 12-15 fragments on floors 48-80
   - Ensure enough fragments BEFORE locked areas
```

**Content IDs needed**:
- `constructions:beton` (walls)
- `constructions:wb_tile1`, `bw_tile1` (chess floors)
- `factory:pipe`, `factory:pipe_valve` (decoration)
- `factory:door_t1/2/3_closed` (progressive doors)
- `default:chest` (key fragment containers)
- `default:ladder` (vertical access)

**Generation Steps**:
1. Fill floor slab (Y=-20 to 0 already done by universal floor)
2. Build perimeter walls
3. Generate floor-by-floor:
   - Lay chess pattern floor
   - Carve corridor grid
   - Place walls around rooms
   - Add doors based on tier zones
4. Carve vertical shafts
5. Place pipes in shafts and corridors
6. Defer chest population with key fragments

---

#### 3. City Generation (Priority: MEDIUM)
**File**: `mods/blocks/uliza/city_gen.lua` (new file)

**Algorithm**:
```
1. Surface generation Y=0 to Y=100
2. Use 501x501 zone footprint
3. Road network:
   - Primary roads: Every 64-96 nodes, 8 nodes wide
   - Align to zone center axes (N-S and E-W through center)
   - Secondary roads: 32-48 node spacing, 6 nodes wide
   - Crosswalks at intersections
   - Material: constructions:beton or default:stone
4. Building parcels:
   - Fill spaces between roads
   - Random building heights: 8-48 nodes tall
   - Footprint: 12x12 to 24x24 nodes
   - Building material: uliza:block (walls), uliza:framed_glass (windows)
   - Flat roofs with access stairs
5. Street furniture:
   - Sidewalks (2 nodes wide, uliza:ground)
   - Lamp posts every 16 nodes (default:torch on fence)
   - Occasional plaza (open space with benches)
```

**Sewer Generation** Y=-100 to Y=0:
```
1. Two-layer tunnel system:
   - Upper level (Y=-10 to -5): Maintenance corridors, 3 tall, 2 wide
   - Lower level (Y=-20 to -15): Water channels, 2 tall, 2 wide
2. Network layout:
   - Align tunnels under major roads
   - Connect at intersections with junctions
3. Access points:
   - Manholes every 32 nodes on roads
   - Ladder shafts connecting to surface
   - Stairwells at major intersections
4. Details:
   - uliza:water_source in lower channels
   - factory:grate at some drainage points
   - Occasional utility rooms (4x4 chambers)
```

**Content IDs needed**:
- `uliza:ground` (surface/sidewalks)
- `constructions:beton` (roads/walls)
- `uliza:block` (building walls)
- `uliza:framed_glass` (windows)
- `default:stone` (sewer walls)
- `uliza:water_source` (sewer water)
- `default:ladder` (access)
- `default:torch` (lighting)

---

### Performance Considerations

#### VoxelManip Best Practices
1. **Single Read/Write**: Already implemented in orchestrator
2. **Cached Content IDs**: Initialize once per generation callback
3. **Clipped Loops**: Only process intersection of chunk and zone bounds
4. **Deferred Operations**: Metadata/entities via deferred queue

#### Per-Generator Optimizations

**Labyrinth**:
- Pre-compute graph before any node placement
- Use simple flood-fill for room carving (not per-node checks)
- Limit ghost trigger count (max 1 per 64 nodes²)

**Factory**:
- Generate floor-by-floor to reduce nested loops
- Cache chess pattern (alternate on x+z coordinate)
- Limit pipe placement to shaft cores only

**City**:
- Pre-compute road grid before building placement
- Use simple rectangle fill for buildings
- Defer complex furniture to post-generation

---

### Testing Checklist

#### Zone System
- [x] Zones deterministically assigned
- [x] Same seed = same zones
- [x] Spawn zone always plain
- [x] Zone boundaries respected

#### Floor Generation
- [x] Floor present at Y=0
- [x] Depth extends to Y=-20
- [x] Surface varies by zone type
- [ ] No gaps or missing chunks

#### Structure Generation
- [ ] Labyrinth rooms navigable
- [ ] Labyrinth doors functional
- [ ] Factory floors accessible
- [ ] Factory keys unlock correct doors
- [ ] City roads form connected network
- [ ] City sewers align with roads
- [ ] No structures overlap zones
- [ ] No crashes on generation

#### Performance
- [ ] Generation time <2s per chunk
- [ ] No lag spikes during exploration
- [ ] Memory usage stable
- [ ] Lighting updates correctly

---

### Debug Commands to Add

```lua
-- Spawn key fragments for testing
/temz_spawn_keys <tier> <count>

-- Force open nearby factory doors
/temz_open_doors <radius>

-- Show zone type grid around player
/temz_gen_preview <radius>

-- Teleport to specific zone type
/temz_tp_type <city|labyrinth|factory>

-- Regenerate current chunk (for testing)
/temz_regen_chunk
```

---

## Asset TODO

### Required Assets
- [ ] Door meshes for sliding animation (see TODO_SLIDING_DOORS.md)
- [ ] Ghost sprite/mesh for labyrinth
- [ ] Pipe textures for factory
- [ ] Tutorial sign textures
- [ ] Key fragment textures (currently placeholders)

### Placeholder Usage (Current)
- Ghost visual: `scary_mob_texture.png`
- Doors: Simple nodebox swap (no animation)
- Keys: Colored ingot textures
- Sounds: Reusing scary/default sounds

---

## Integration with Existing Systems

### Floating Islands (Currently Disabled)
- Re-enable after zone generation stable
- Islands should generate ABOVE zone structures (Y>100)
- Modify island gen to respect zone system
- Ensure islands don't interfere with factory tops

### Entity Systems
- Scary mobs should spawn in labyrinths primarily
- Ghost triggers need mapblock indexing for performance
- Factory locked doors need inventory checks

---

## Estimated Completion Time

- **Labyrinth Basic**: 2-3 hours (maze algorithm + carving)
- **Factory Basic**: 3-4 hours (multi-floor logic + key system)
- **City Basic**: 3-4 hours (road network + simple buildings)
- **Sewers**: 2 hours (tunnel network + access points)
- **Polish & Testing**: 2-3 hours
- **Total**: ~12-15 hours of focused work

## Current Session Progress

**Completed Today** (Session 1):
- Zone system architecture ✅
- Universal floor generation ✅
- Orchestrator framework ✅
- Mod scaffolding ✅
- Debug commands ✅

**Next Session Goals**:
- Implement labyrinth maze generation
- Test navigability and performance
- Add basic ghost trigger placement
