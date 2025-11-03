# Quick Testing Guide - Running System

## Start the Game
1. Launch Minetest with the temnaya_zashelina game
2. Create/join a world

## Basic Sprint Test
1. Walk around normally (W/A/S/D keys)
2. Hold **E key (Aux1)** while moving forward
3. You should:
   - Move faster (1.5x speed)
   - See a stamina bar appear at the bottom of screen
   - Notice a slight FOV zoom effect
4. Release E key - speed should return to normal
5. Sprint until stamina depletes (takes ~200 seconds base)
6. Try to sprint with 0 stamina - should not work
7. Wait for stamina to regenerate

## Ability System Integration Test

### Get Stat Points
Run this command to give yourself stat points:
```
/givestatpoints <your_name> 20
```

### Test Sprint Stamina Ability
1. Open abilities menu: Press **I** key, click **⚡** tab
2. Find "Sprint Stamina" ability (🫁 icon) at position (0, -1)
3. Click to unlock (costs 1 point per level)
4. Check HUD - max stamina should increase by 20
5. Unlock multiple levels - max stamina increases to 200 at level 5

### Test Sprint Efficiency Ability
1. Find "Sprint Efficiency" ability (⚡ icon) at position (1, -1)
2. Unlock after Sprint Stamina (requires Sprint Stamina)
3. Sprint - notice stamina drains slower
4. At level 3, drain rate is 55% of normal

### Test Run Speed Ability
1. Find "Run Speed" ability (🏃 icon) at position (1, 0)
2. Unlock after Walk Speed
3. Sprint - notice increased sprint speed
4. At level 5, sprint speed is 2.0x base speed

### Test Dash Ability (Infinite Sprint)
1. Find "Dash" ability (💨 icon) at position (2, 0)
2. Unlock after Run Speed (costs 2 points)
3. In abilities menu, find it in the toggle list
4. Click to toggle ON
5. Sprint - stamina bar should show "∞ (Infinite)"
6. Sprint indefinitely without stamina drain

### Test Sprint HUD Toggle
1. Find "Sprint HUD" ability (📊 icon) at position (-1, 0)
2. Unlock (costs 0 points - free!)
3. Toggle ON - HUD appears
4. Toggle OFF - HUD disappears
5. Stamina still works, just HUD is hidden

## Edge Cases to Test

### Water Test
1. Jump into water
2. Try to sprint - should not work in water
3. Exit water - sprint should work again

### No Movement Test
1. Stand still
2. Hold E key
3. Should not sprint (must be moving)

### Sneak Test
1. Hold Shift (sneak)
2. Try to sprint
3. Should not sprint while sneaking

### Logout/Login Test
1. Sprint until stamina is at 50%
2. Logout
3. Login again
4. Stamina should be restored/persisted
5. Physics should be correct (not stuck sprinting)

## Expected Behavior

### Sprint Active
- ✅ Speed: Base speed × 1.5 (+ run speed bonuses)
- ✅ Jump: Base jump × 1.2
- ✅ FOV: Normal FOV × 1.1
- ✅ Stamina: Draining (or infinite if Dash enabled)
- ✅ HUD: Green/Yellow/Red based on stamina level

### Sprint Inactive
- ✅ Speed: Normal base speed
- ✅ Jump: Normal base jump
- ✅ FOV: Normal
- ✅ Stamina: Regenerating at 2x drain rate
- ✅ HUD: Shows current/max stamina

## Debug Commands

### Give yourself stat points
```
/givestatpoints <name> <amount>
```

### Check your abilities (open abilities GUI)
```
/abilities2
```

### Grant yourself server privileges (if needed)
```
/grant <name> server
```

## Common Issues

### Sprint not working
- Check if you have stamina (HUD shows >0)
- Verify you're pressing Aux1 key (E by default)
- Make sure you're moving (pressing W/A/S/D)
- Confirm you're not in water

### HUD not showing
- Check if Sprint HUD ability is unlocked and toggled ON
- Verify no other mods are conflicting with HUD position

### Stamina not draining/regenerating
- Check console for Lua errors
- Verify running_system.lua loaded correctly
- Look for "[running_system] Sprint system with Aux1 key loaded!" message

### Physics stuck
- Logout and login again
- Check for physics override conflicts with other mods
- Verify ability_system_new.lua is working correctly

## Success Criteria
✅ Sprint activates with Aux1 key  
✅ Stamina system works (drain/regen)  
✅ HUD displays correctly with colors  
✅ All abilities function as described  
✅ No Lua errors in debug.txt  
✅ Physics restore correctly on logout/login  
