# USSR Microdistrict City Generation - Implementation Plan

## Overview
Generate Soviet-style residential districts (microdistricts/mikrorayon) with focus on exterior appearance, pedestrian paths, recreation zones, and placeholder buildings for later schematic replacement.

## Phase 1: Exterior Infrastructure (Current Focus)

### 1.1 Microdistrict Block Layout (60×60 nodes)
```
┌────────────────────────────────────────────────────────┐
│ Path (4 wide)                                          │
├────────────────────────────────────────────────────────┤
│                                                        │
│  Building Zone (56×56)                                │
│  - Panel buildings (placeholder cuboids)              │
│  - Recreation zones (25%)                             │
│  - Courtyard space between buildings                  │
│                                                        │
└────────────────────────────────────────────────────────┘
```

### 1.2 Path System
**Pedestrian Paths (80% of blocks)**:
- Width: 4 nodes
- Material: `uliza:sidewalk` (concrete)
- Placement: Along block edges (X and Z sides)
- Lighting: Lamps every 16 nodes

**Asphalt Roads (20% of blocks)**:
- Width: 4-8 nodes (wider than paths)
- Material: `uliza:asphalt`
- Purpose: Vehicle access (rare)
- Placement: Same positions as paths but wider

**Logic**:
```lua
-- Check if this block gets road or path
local has_road_x = hash(block_x, block_z, seed) % 100 < 20
local has_road_z = hash(block_x, block_z, seed+1) % 100 < 20

-- Place accordingly
if in_path_zone then
    if has_road then
        place_asphalt(wider)
    else
        place_sidewalk(normal)
    end
end
```

### 1.3 Building Placement (Placeholder Cuboids)
**Panel Building Dimensions**:
- Standard: 12×40 nodes footprint
- Height: 20 nodes (5 floors) or 36 nodes (9 floors)
- Orientation: N-S (12×40) or E-W (40×12)
- Material: `constructions:beton` or `constructions:white_bricks2`

**Placement Rules**:
- Center in building zone with small offset
- 2-3 buildings per 60×60 block
- Space between buildings: 8-12 nodes (courtyards)
- Entrances face paths

**Cuboid Generation** (temporary):
```lua
-- Simple solid cuboid for now
for x in building_footprint do
    for z in building_footprint do
        for y = 1 to height do
            if on_perimeter then
                place_exterior_wall()
            else
                place_air()  -- Hollow
            end
        end
    end
end
```

### 1.4 Recreation Zones (25% of blocks)
Replace building zone with:

**Elements**:
- Trees: `uliza:tree1` at 1-2% density (sparse!)
- Playground structures:
  - Climbing frames: stacked `constructions:white_bricks2` (3-4 nodes tall)
  - Benches: horizontal `constructions:beton` (2 nodes long, 1 tall)
  - Sandbox: `default:sand` patch (4×4 nodes)
- Green space: `uliza:ground` with occasional flowers

**Layout**:
```lua
if is_recreation_zone(block_x, block_z) then
    -- Sparse trees
    if hash(x, z) % 100 < 2 then
        place_tree()
    end
    
    -- Playground elements (5% of zone)
    if hash(x, z) % 100 < 5 then
        place_playground_element()
    end
    
    -- Rest is grass
    place_ground()
end
```

### 1.5 Lighting
**Street Lamps**:
- Spacing: Every 16 nodes along paths
- Height: 5 nodes (pole + lamp)
- Structure:
  - Nodes 1-4: `constructions:beton` (pole)
  - Node 5: `uliza:street_lamp` (light_source=14)

**Placement Logic**:
```lua
if (rel_x % 16 == 0 or rel_z % 16 == 0) and on_path_edge then
    for y = 1, 5 do
        place_lamp_component(y)
    end
end
```

### 1.6 Ground Level Details
**Courtyard Features** (between buildings):
- Benches along paths
- Trash bins (simple concrete blocks)
- Bicycle racks (fence sections)
- Drying racks (fence posts with crossbars)
- Small gardens (patches of flowers/crops)

## Phase 2: Building Schematics (Future)

### 2.1 Schematic Creation
**Building Templates**:
1. `panel_5floor_12x40_type1.mts` - Standard 5-story
2. `panel_9floor_12x40_type1.mts` - Standard 9-story
3. `panel_9floor_40x12_type1.mts` - Rotated 9-story
4. Variants with different layouts

**Interior Structure** (for schematics):
```
Each 4-node floor:
├─ Y+0: Floor slab (concrete)
├─ Y+1-3: Living space
│  ├─ Exterior walls on perimeter
│  ├─ Windows on exterior (every 3-4 nodes)
│  ├─ Interior walls (apartment divisions)
│  ├─ Doors between rooms
│  └─ Stairwell (compact, 2×3 nodes)
└─ Y+4: Next floor slab
```

**Apartment Layout** (per floor):
- 2-4 apartments per floor
- Typical apartment:
  - Entrance hall: 2×2
  - Living room: 4×5 with balcony door
  - Bedroom: 3×4 with window
  - Kitchen: 2×3 with window
  - Bathroom: 2×2 (no window)
  - Balcony: 1×length of building (exterior)

### 2.2 Schematic Integration
**Loading**:
```lua
local schematics = {
    panel_5_ns = {
        path = modpath .. "/schematics/panel_5floor_12x40_type1.mts",
        size = {x=12, y=20, z=40},
        rotation = "0",
    },
    panel_9_ns = {
        path = modpath .. "/schematics/panel_9floor_12x40_type1.mts",
        size = {x=12, y=36, z=40},
        rotation = "0",
    },
    -- ... more variants
}
```

**Placement**:
```lua
-- Replace cuboid generation with:
local schem = choose_schematic(block_x, block_z, seed)
local rotation = get_orientation(block_x, block_z, seed)
minetest.place_schematic_on_vmanip(
    vm, 
    building_pos, 
    schem.path, 
    rotation,
    nil,
    true
)
```

## Phase 3: Details and Polish (Future)

### 3.1 Building Variations
- Different balcony styles
- Ground floor shops (different windows/doors)
- Different roof structures (flat, technical floor, pitched)
- Different facade materials/colors

### 3.2 Courtyard Detailing
- Parking areas (asphalt patches)
- Entrance canopies (shelter nodes above doors)
- Garbage collection areas (fenced zones)
- Children's playgrounds (swings, slides, sandboxes)
- Sports areas (basketball courts, simple goals)

### 3.3 Vegetation
- Trees along paths (planned rows, not random)
- Shrubs around building foundations
- Flower beds near entrances
- Grass patches vs worn dirt paths

### 3.4 Urban Furniture
- Benches (actual bench nodes or simple blocks)
- Trash bins
- Street signs
- Lamp posts (decorative variants)
- Bike racks
- Clotheslines (in courtyards)

## Technical Implementation Details

### Data Structures
```lua
-- Building template
{
    type = "panel_9floor",
    width = 12,
    depth = 40,
    height = 36,
    floors = 9,
    material = "beton" or "bricks",
    orientation = 0 or 90,  -- degrees
    schematic = "path/to/file.mts" or nil,
}

-- Microdistrict block
{
    block_x = 0,
    block_z = 0,
    type = "residential" or "recreation",
    has_road_x = true/false,
    has_road_z = true/false,
    buildings = {
        {pos, template, rotation},
        {pos, template, rotation},
    },
}
```

### Generation Order
1. **Pass 1: Terrain base**
   - Fill underground with stone
   - Place ground layer
   - Clear air above

2. **Pass 2: Infrastructure**
   - Generate paths/roads
   - Place street lamps
   - Mark building zones

3. **Pass 3: Buildings**
   - For residential blocks: place building cuboids/schematics
   - For recreation blocks: place playground elements, trees

4. **Pass 4: Details** (future)
   - Courtyard furniture
   - Vegetation
   - Ground-level decorations

### Hash-Based Randomness
All randomness deterministic from position:
```lua
function hash_pos(x, z, seed)
    local h = seed
    h = (h + x * 374761393) % 2147483647
    h = (h + z * 668265263) % 2147483647
    h = (h * 1664525 + 1013904223) % 2147483647
    return h
end

-- Usage:
local block_type = hash_pos(block_x, block_z, zone_seed) % 100
if block_type < 25 then
    -- Recreation zone
else
    -- Residential zone
end
```

### Performance Considerations
- Use VoxelManip for bulk terrain
- Cache content IDs
- Batch schematic placements
- Skip generation outside Y bounds
- Use efficient loops (Z outer, X middle, Y inner)

## Constants and Tuning

```lua
-- Microdistrict layout
BLOCK_SIZE = 60              -- Microdistrict block size
PATH_WIDTH = 4               -- Pedestrian path width
ROAD_WIDTH = 8               -- Vehicle road width (when present)

-- Building dimensions
BUILDING_WIDTH = 12          -- Panel building width
BUILDING_DEPTH = 40          -- Panel building length
BUILDING_HEIGHT_5 = 20       -- 5-story building
BUILDING_HEIGHT_9 = 36       -- 9-story building
FLOOR_HEIGHT = 4             -- Nodes per floor

-- Probabilities (%)
ROAD_PROBABILITY = 20        -- % of paths that are asphalt roads
RECREATION_PROBABILITY = 25  -- % of blocks that are recreation
TREE_DENSITY = 2             -- % in recreation zones
PLAYGROUND_DENSITY = 5       -- % in recreation zones

-- Lighting
LAMP_SPACING = 16            -- Distance between lamps
LAMP_HEIGHT = 5              -- Total lamp post height

-- Courtyard spacing
MIN_BUILDING_GAP = 8         -- Minimum space between buildings
MAX_BUILDING_GAP = 15        -- Maximum space between buildings
```

## Testing Checklist

### Phase 1 (Current):
- [ ] Paths generate in grid pattern
- [ ] 80% are sidewalk, 20% are asphalt
- [ ] Lamps placed at correct spacing
- [ ] Building cuboids have correct dimensions
- [ ] Buildings are hollow (air inside)
- [ ] Buildings use beton/brick materials
- [ ] Recreation zones appear 25% of time
- [ ] Trees are sparse (1-2% in recreation)
- [ ] Playground elements present
- [ ] Ground is properly filled
- [ ] Underground is stone

### Phase 2 (Future with schematics):
- [ ] Schematics load correctly
- [ ] Schematics place at correct positions
- [ ] Rotations work properly
- [ ] Building interiors are complete
- [ ] Windows are in correct positions
- [ ] Doors are functional
- [ ] Stairwells are accessible

### Phase 3 (Polish):
- [ ] Courtyard details present
- [ ] Vegetation looks natural
- [ ] Urban furniture functional
- [ ] No z-fighting or rendering issues

## Files Structure

```
mods/dumbgen2/
├── city.lua                 # Main generator (rewrite)
├── schematics/             # Building templates (future)
│   ├── panel_5floor_12x40_type1.mts
│   ├── panel_9floor_12x40_type1.mts
│   └── panel_9floor_40x12_type1.mts
├── CITY_GENERATION.md       # User documentation
├── CITY_IMPLEMENTATION_PLAN.md  # This file
└── CITY_SUMMARY.md          # Quick reference

mods/blocks/uliza/
└── init.lua                 # City nodes (paths, lamps, slabs)
```

## Notes
- Focus on realistic Soviet microdistrict aesthetics
- Pedestrian-friendly design (minimal cars)
- Standardized building templates (like real panel construction)
- Space-efficient layouts (dense but with green space)
- Recreation zones for community life
- Simple, functional, brutalist architecture
