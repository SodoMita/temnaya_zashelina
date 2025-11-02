# TODO: Implement Proper Sliding Door Animations

## Current Status
Both `labyrinth:slide_door_*` and `factory:door_t*_*` currently use simple node state swaps (closed ↔ open) without visual animation.

## Reference Implementation
See `/home/hobo/.minetest/games/artifact/mods/artifact_tech/doors.lua` for a working example of entity-based sliding doors.

## Key Concepts from Artifact Doors

### Architecture
1. **Anchor Node** (`artifact:3door`): Airlike, invisible node that acts as the control point
2. **Visual Entities** (`artifact:3door_slice`): 3 separate entities that render the door in slices
3. **Collider Entity** (`artifact:3door_slice_collider`): Attached to visual entity for collision detection
4. **Timer-based activation**: Uses node timer to check for nearby players

### Animation Method
- Uses `entity:set_velocity(vector.new(0, 3, 0))` for smooth movement
- Slides vertically upward when opening (3 nodes/second for 1 second)
- Slides back down when closing
- Each slice has a staggered timer (0, 0.5, 1 second) for cascading effect

### State Management
- Stores state in node metadata: `"open"`, `"on"`, `"always_on"`, `"initialized"`
- `_animating` flag prevents overlapping animations
- `_state` tracks current door state

## Adaptation for Labyrinth/Factory

### Labyrinth Doors (Horizontal Sliding)
- Should slide **horizontally** to the side instead of vertically
- Single entity or 2-entity design (simpler than 3 slices)
- Use `vector.new(2, 0, 0)` for horizontal velocity
- Triggered by right-click, auto-closes after 5 seconds
- **No lock** - purely atmospheric

### Factory Doors (Vertical Sliding with Lock)
- Similar to artifact but with key fragment requirement check
- Check inventory for required fragments **before** opening
- Optional fragment consumption (setting-based)
- Three tiers with different visual styles
- Auto-close after 10 seconds

## Implementation Steps
1. Create door entity definitions with proper mesh/sprite
2. Implement anchor node with on_construct spawning entities
3. Add velocity-based animation in entity on_step or via minetest.after
4. Handle collision properly (attached collider entity or built-in collisionbox)
5. Add sounds at animation start and end
6. Test with generation code to ensure doors spawn correctly in structures

## Assets Needed
- Door meshes or sprites for visual entities
- Collision boxes matching door dimensions
- Sound effects for sliding (can reuse scary/artifact sounds temporarily)
- Textures for different door tiers (factory)

## Priority
**AFTER** basic map generation is working. Doors are only useful once we have labyrinth/factory structures to place them in.
