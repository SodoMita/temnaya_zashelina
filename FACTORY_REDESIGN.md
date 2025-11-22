# Factory Generation Redesign - Functional Technic Networks

## Core Concept
Generate a factory complex with working technic power networks. Each building has a purpose and functional infrastructure.

## Building Types

### 1. Power Plant (50×50, Y=0-40, 5 floors)
**Purpose**: Primary power generation
- **Ground Floor (Y=0-7)**: 
  - 3-4 `technic:hv_generator` or `technic:coal_alloy_furnace` with fuel
  - `technic:hv_battery_box` for storage
  - HV cables connecting to switching station
- **Second Floor (Y=8-15)**: Control room
  - `technic:switching_station` (network anchor)
  - `technic:power_monitor`
  - Cables running to other buildings
- **Basement (Y=-8 to -1)**: 
  - `technic:geothermal` generators (if near lava/heat)
  - Fuel storage (`default:chest` with coal)

### 2. Main Production Hall A (80×120, Y=0-24, 3 floors)
**Purpose**: LV/MV manufacturing
- **Ground Floor**: 
  - 8-12 `technic:lv_electric_furnace`, `lv_grinder`, `lv_compressor`
  - Arranged in production line layout
  - LV cables from ceiling
  - `technic:lv_battery_box` for local storage
- **Second Floor**: Catwalk with cable runs
  - LV cables running along ceiling
  - `technic:mv_cable` trunk lines
- **Third Floor**: MV machines (requires T1 key)
  - `technic:mv_grinder`, `mv_compressor`
  - Connected to MV network

### 3. Production Hall B (70×100, Y=0-32, 4 floors)
**Purpose**: MV/HV advanced manufacturing
- **Floors 1-2**: MV production area
  - Similar to Hall A but MV tier
- **Floors 3-4**: HV machines (requires T2 key)
  - `technic:hv_grinder`, etc.
  - HV cable network

### 4. Central Tower (30×30, Y=0-88, 11 floors)
**Purpose**: Administration + Secure Power
- **Floors 1-3**: Offices (3dforniture furniture, no power needed)
- **Floors 4-7**: Data center (T2 access)
  - Rows of `technic:lv_lamp` (powered lighting)
  - `technic:music_player` (servers?)
  - Heavy power draw, needs battery backup
- **Floors 8-11**: Nuclear facility (T3 access)
  - `technic:hv_nuclear_reactor_core` (main power source)
  - `technic:hv_battery_box` arrays
  - HV cables down to switching station

### 5. Workshop/Maintenance Building (40×60, Y=0-16, 2 floors)
**Purpose**: Tool production and repair
- Workbenches with adjacent machines
- `technic:tool_workshop`, welders, etc.
- LV network

## Cable Infrastructure

### Underground Cable Tunnels (Y=-20 to -5)
- Main trunk lines connecting buildings
- HV cables in protective concrete conduits
- Junction boxes at intersections
- Emergency lighting (`technic:lv_lamp` on separate circuit)
- Access through manholes and ladder shafts

### Vertical Cable Shafts
- Each building has 1-2 vertical shafts
- Cables run vertically between floors
- `technic:concrete_post` as cable supports
- Ladder access for maintenance

### Cable Routing Rules
1. **Generators → Switching Station → Machines**
2. Use appropriate tier: LV for low power, HV for main distribution
3. Cables run along walls/ceilings (not random placement)
4. Battery boxes near high-draw machine clusters
5. Include some damaged sections (broken cables, missing machines)

## Power Network Design

### Network Hierarchy
```
HV Nuclear Reactor (Tower Floor 10)
  ↓ HV Cables
HV Generators (Power Plant)
  ↓ HV Cables  
Switching Station (Power Plant Floor 2)
  ↓ Branch to MV
MV Battery Boxes
  ↓ MV Cables
MV Machines (Production Halls)
  ↓ Step down to LV
LV Battery Boxes
  ↓ LV Cables
LV Machines (Ground floors)
```

### Generation Algorithm

1. **Place Buildings** (structure, walls, floors)
2. **Place Switching Station** (Power Plant Floor 2, center)
3. **Place Generators** near switching station
   - Connect with HV cables
   - Add fuel in chests
4. **Place Battery Boxes** in each building
   - Connect to switching station with appropriate tier cables
5. **Place Machines** in production areas
   - Group by tier (LV/MV/HV)
   - Connect to nearest battery box
6. **Run Cable Routes**
   - Ceiling/wall mounted cables
   - Underground trunk lines
   - Use `technic:concrete_post` for supports
7. **Add Furniture** in non-industrial areas (offices, break rooms)
8. **Place Loot**
   - Key fragments in offices/secure areas
   - Fuel/batteries in storage
   - Robot parts near workstations

## Visual Details

- Use `technic:concrete` for industrial floors
- `technic:stainless_steel_block` for machinery housings  
- `technic:cast_iron_block` for heavy equipment bases
- `technic:insulator_clip` on cable posts
- `3dforniture:table`, `chair` in offices
- Warning signs near dangerous equipment
- Emergency lighting (lamps on separate circuit)

## Progression Integration

- **T1 doors**: Block access to MV production areas
- **T2 doors**: Block HV manufacturing and data center
- **T3 doors**: Block nuclear reactor and director's vault
- Key fragments placed in logical locations (supervisor office, security room, reactor control)

## Implementation Notes

- Generate building structures first (VoxelManip)
- Use deferred queue for technic nodes (need metadata/network setup)
- Ensure cables form valid paths (no broken segments unless intentional damage)
- Add some "powered off" machines (empty generators, dead batteries) for atmosphere
- Include coal/fuel in generator inventories so network could theoretically work
