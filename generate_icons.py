import os
from PIL import Image, ImageDraw

ICON_SIZE = 64
COLOR = (255, 255, 255, 255)  # White
TRANSPARENT = (0, 0, 0, 0)
OUTPUT_DIR = "mods/gui/textures"

os.makedirs(OUTPUT_DIR, exist_ok=True)

def create_base_image():
    return Image.new("RGBA", (ICON_SIZE, ICON_SIZE), TRANSPARENT)

def save_icon(img, name):
    path = os.path.join(OUTPUT_DIR, name)
    img.save(path)
    print(f"Saved {path}")

def draw_pickaxe(draw):
    # Handle
    draw.line([(16, 48), (48, 16)], fill=COLOR, width=4)
    # Head
    draw.arc([32, 0, 64, 32], 180, 270, fill=COLOR, width=6)
    draw.polygon([(44, 12), (52, 4), (56, 8), (48, 16)], fill=COLOR) # Point
    draw.polygon([(12, 44), (4, 52), (8, 56), (16, 48)], fill=COLOR) # Point

def draw_block(draw):
    draw.rectangle([16, 16, 48, 48], outline=COLOR, width=3)
    draw.line([(16, 16), (48, 48)], fill=COLOR, width=1)
    draw.line([(48, 16), (16, 48)], fill=COLOR, width=1)

def draw_star(draw):
    # Simple star
    cx, cy = 32, 32
    points = []
    import math
    outer_radius = 24
    inner_radius = 10
    for i in range(10):
        angle = i * math.pi / 5 - math.pi / 2
        r = outer_radius if i % 2 == 0 else inner_radius
        x = cx + r * math.cos(angle)
        y = cy + r * math.sin(angle)
        points.append((x, y))
    draw.polygon(points, outline=COLOR, fill=None) # Outline only for monochrome feel

def draw_ghost(draw):
    draw.ellipse([16, 10, 48, 42], outline=COLOR, width=2)
    draw.rectangle([16, 26, 48, 54], outline=COLOR, width=2) # Body
    # Eyes
    draw.ellipse([24, 22, 28, 26], fill=COLOR)
    draw.ellipse([36, 22, 40, 26], fill=COLOR)

def draw_skull(draw):
    draw.ellipse([18, 12, 46, 40], outline=COLOR, width=2)
    draw.rectangle([24, 40, 40, 50], outline=COLOR, width=2)
    draw.ellipse([24, 24, 30, 30], fill=COLOR)
    draw.ellipse([34, 24, 40, 30], fill=COLOR)

def draw_island(draw):
    draw.arc([10, 32, 30, 52], 0, 360, fill=COLOR, width=2) # Cloud
    draw.arc([34, 32, 54, 52], 0, 360, fill=COLOR, width=2) # Cloud
    draw.polygon([(20, 32), (32, 10), (44, 32)], outline=COLOR) # Mountain

def draw_boot(draw):
    draw.polygon([(20, 20), (20, 44), (40, 44), (40, 36), (28, 36), (28, 20)], outline=COLOR, width=2)

def draw_hammer(draw):
    draw.rectangle([28, 20, 36, 56], fill=COLOR) # Handle
    draw.rectangle([16, 16, 48, 24], fill=COLOR) # Head

def draw_lightning(draw):
    draw.polygon([(32, 8), (20, 32), (32, 32), (28, 56), (44, 24), (32, 24)], fill=COLOR)

def draw_fire(draw):
    draw.ellipse([24, 24, 40, 52], outline=COLOR, width=2)
    draw.polygon([(32, 12), (24, 32), (40, 32)], fill=COLOR)

def draw_diamond(draw):
    draw.polygon([(32, 10), (54, 32), (32, 54), (10, 32)], outline=COLOR, width=3)

def draw_crown(draw):
    draw.polygon([(12, 44), (12, 20), (22, 32), (32, 16), (42, 32), (52, 20), (52, 44)], outline=COLOR, width=2)

def draw_egg(draw):
    draw.ellipse([20, 12, 44, 52], outline=COLOR, width=3)

def draw_spiral(draw):
    draw.arc([16, 16, 48, 48], 0, 360, fill=COLOR, width=2)
    draw.arc([24, 24, 40, 40], 0, 360, fill=COLOR, width=2)

def draw_building(draw):
    draw.rectangle([20, 16, 44, 48], outline=COLOR, width=2)
    draw.rectangle([24, 20, 28, 24], fill=COLOR)
    draw.rectangle([36, 20, 40, 24], fill=COLOR)
    draw.rectangle([24, 30, 28, 34], fill=COLOR)
    draw.rectangle([36, 30, 40, 34], fill=COLOR)

def draw_window(draw):
    draw.rectangle([16, 16, 48, 48], outline=COLOR, width=3)
    draw.line([(32, 16), (32, 48)], fill=COLOR, width=2)
    draw.line([(16, 32), (48, 32)], fill=COLOR, width=2)

def draw_wrench(draw):
    draw.line([(20, 44), (44, 20)], fill=COLOR, width=4)
    draw.arc([40, 10, 54, 24], 0, 360, fill=COLOR, width=3)

def draw_anvil(draw):
    draw.polygon([(16, 24), (48, 24), (40, 44), (24, 44)], fill=COLOR)
    draw.rectangle([28, 44, 36, 52], fill=COLOR)

def draw_crane(draw):
    draw.line([(16, 48), (16, 20)], fill=COLOR, width=2) # Mast
    draw.line([(16, 20), (48, 20)], fill=COLOR, width=2) # Jib
    draw.line([(16, 20), (32, 48)], fill=COLOR, width=1) # Support
    draw.line([(48, 20), (48, 32)], fill=COLOR, width=1) # Cable

def draw_feather(draw):
    draw.arc([20, 10, 44, 54], 0, 180, fill=COLOR, width=2)
    draw.line([(32, 10), (32, 54)], fill=COLOR, width=1)

def draw_bubbles(draw):
    draw.ellipse([20, 40, 26, 46], outline=COLOR, width=1)
    draw.ellipse([30, 30, 38, 38], outline=COLOR, width=2)
    draw.ellipse([24, 16, 34, 26], outline=COLOR, width=2)

def draw_wing(draw):
    draw.polygon([(16, 32), (48, 16), (56, 24), (40, 40), (24, 40)], outline=COLOR, width=2)

def draw_arrow_up(draw):
    draw.line([(32, 48), (32, 16)], fill=COLOR, width=4)
    draw.line([(32, 16), (20, 28)], fill=COLOR, width=4)
    draw.line([(32, 16), (44, 28)], fill=COLOR, width=4)


# Map names to draw functions
icons = {
    "achievement_first_dig.png": draw_pickaxe,
    "achievement_place_10_blocks.png": draw_block,
    "achievement_dig_100_blocks.png": lambda d: (draw_pickaxe(d), draw_block(d)),
    "achievement_reach_level_5.png": draw_star,
    "achievement_first_ghost.png": draw_ghost,
    "achievement_ghost_hunter.png": lambda d: (draw_ghost(d), draw_pickaxe(d)), # Reuse pickaxe as 'weapon'
    "achievement_ghost_veteran.png": draw_skull,
    "achievement_visit_floating_island.png": draw_island,
    "achievement_find_city.png": draw_building,
    "achievement_travel_1000_blocks.png": draw_boot,
    "achievement_visit_10_islands.png": lambda d: (draw_island(d), d.text((40,40), "10", fill=COLOR)),
    "achievement_first_craft.png": draw_hammer,
    "achievement_craft_10_items.png": draw_wrench,
    "achievement_craft_100_items.png": draw_anvil,
    "achievement_craft_urban_item.png": draw_crane,
    "achievement_craft_glass.png": draw_window,
    "achievement_unlock_first_ability.png": draw_lightning,
    "achievement_unlock_5_abilities.png": draw_fire,
    "achievement_max_ability.png": lambda d: (draw_star(d), draw_lightning(d)),
    "achievement_unlock_all_movement.png": draw_wing,
    "achievement_reach_level_10.png": lambda d: (draw_star(d), d.text((20,20),"10", fill=COLOR)),
    "achievement_reach_level_25.png": draw_diamond,
    "achievement_reach_level_50.png": draw_crown,
    "achievement_dig_1000_blocks.png": lambda d: (draw_pickaxe(d), d.text((32,32),"1k", fill=COLOR)),
    "achievement_place_1000_blocks.png": lambda d: (draw_block(d), d.text((32,32),"1k", fill=COLOR)),
    "achievement_secret_find_depths.png": draw_spiral,
    "achievement_secret_easter_egg.png": draw_egg,
    
    "ability_speed.png": draw_boot,
    "ability_jump.png": draw_arrow_up,
    "ability_gravity.png": draw_feather,
    "ability_breath.png": draw_bubbles,
}

for name, func in icons.items():
    img = create_base_image()
    draw = ImageDraw.Draw(img)
    try:
        func(draw)
    except Exception as e:
        print(f"Error drawing {name}: {e}")
    save_icon(img, name)
