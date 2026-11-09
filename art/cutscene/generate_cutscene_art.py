from PIL import Image, ImageDraw

def create_lab_desk():
    # Desk 160x70
    w, h = 160, 70
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Table top (thickness 12px)
    d.rectangle([10, 10, 150, 22], fill=(225, 218, 196, 255), outline=(130, 120, 100, 255))
    # Bevel highlight
    d.line([11, 11, 149, 11], fill=(245, 240, 225, 255))
    d.line([11, 21, 149, 21], fill=(160, 150, 130, 255))
    
    # Metal legs
    d.rectangle([18, 22, 26, 68], fill=(90, 95, 105, 255), outline=(50, 55, 65, 255))
    d.rectangle([134, 22, 142, 68], fill=(90, 95, 105, 255), outline=(50, 55, 65, 255))
    # Crossbar
    d.rectangle([26, 50, 134, 55], fill=(70, 75, 85, 255))
    # Rubber feet
    d.rectangle([16, 66, 28, 69], fill=(30, 30, 35, 255))
    d.rectangle([132, 66, 144, 69], fill=(30, 30, 35, 255))
    
    img.save("lab_desk.png")

def create_pc_screens():
    # Monitor size: 64x60 (stand + screen)
    def base_monitor(screen_bg):
        img = Image.new("RGBA", (70, 65), (0, 0, 0, 0))
        d = ImageDraw.Draw(img)
        # Stand base
        d.rectangle([25, 58, 45, 62], fill=(60, 64, 70, 255), outline=(30, 32, 36, 255))
        # Stand neck
        d.rectangle([32, 48, 38, 58], fill=(80, 85, 92, 255))
        # Frame
        d.rectangle([8, 8, 62, 48], fill=(40, 44, 52, 255), outline=(20, 22, 26, 255))
        # Inner screen (width 50, height 36)
        d.rectangle([10, 10, 60, 46], fill=screen_bg)
        return img, d

    # 1. Screen Working (99% Report)
    img1, d1 = base_monitor((24, 32, 48, 255))
    # Code lines
    d1.rectangle([13, 14, 45, 16], fill=(70, 180, 120, 255))
    d1.rectangle([13, 19, 52, 21], fill=(100, 200, 255, 255))
    d1.rectangle([13, 24, 38, 26], fill=(220, 180, 90, 255))
    # Progress Bar Box
    d1.rectangle([13, 31, 57, 39], outline=(200, 200, 200, 255), fill=(10, 15, 25, 255))
    # Green progress 99%
    d1.rectangle([15, 33, 54, 37], fill=(46, 204, 113, 255))
    # "99%" text dot simulation
    d1.point([(34, 28), (35, 28)], fill=(255, 255, 255, 255))
    img1.save("screen_working.png")

    # 2. Screen Glitch / Sparks
    img2, d2 = base_monitor((40, 15, 20, 255))
    # Glitch lines
    d2.line([10, 16, 60, 16], fill=(255, 255, 0, 255), width=2)
    d2.line([10, 28, 60, 28], fill=(0, 255, 255, 255), width=2)
    d2.line([10, 38, 60, 38], fill=(255, 50, 50, 255), width=2)
    # Sparks
    d2.polygon([(25, 20), (32, 10), (30, 25), (42, 18), (33, 32), (28, 24)], fill=(255, 255, 255, 255))
    d2.polygon([(45, 22), (52, 12), (50, 27), (58, 20), (49, 36)], fill=(255, 230, 50, 255))
    img2.save("screen_glitch.png")

    # 3. Screen Error Alert (BSOD / Emergency Red)
    img3, d3 = base_monitor((180, 20, 20, 255))
    # Big Warning Triangle / Exclamation
    d3.polygon([(35, 14), (20, 40), (50, 40)], fill=(255, 220, 0, 255), outline=(0, 0, 0, 255))
    # Exclamation mark
    d3.rectangle([34, 22, 36, 32], fill=(0, 0, 0, 255))
    d3.rectangle([34, 35, 36, 37], fill=(0, 0, 0, 255))
    img3.save("screen_alert.png")

def create_keyboard():
    # Keyboard 36x12
    img = Image.new("RGBA", (38, 14), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle([1, 2, 36, 12], fill=(60, 64, 72, 255), outline=(30, 32, 36, 255))
    # Keys
    for y in range(4, 11, 3):
        for x in range(3, 35, 4):
            d.rectangle([x, y, x+2, y+1], fill=(180, 185, 195, 255))
    img.save("keyboard.png")

def create_coffee_mug():
    # Standing mug 20x24
    img = Image.new("RGBA", (24, 26), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Handle
    d.arc([2, 9, 10, 21], 90, 270, fill=(192, 57, 43, 255), width=2)
    # Cup body
    d.rectangle([8, 8, 20, 22], fill=(231, 76, 60, 255), outline=(150, 30, 20, 255))
    # Coffee inside top
    d.ellipse([9, 7, 19, 10], fill=(78, 42, 20, 255))
    # Steam
    d.line([12, 5, 14, 2], fill=(220, 220, 220, 160))
    d.line([16, 6, 18, 3], fill=(220, 220, 220, 160))
    img.save("coffee_mug_up.png")

def create_coffee_spill():
    # Spilled mug and brown puddle spreading 50x26
    img = Image.new("RGBA", (54, 26), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Spilled Mug tilted on side
    d.rectangle([6, 10, 20, 22], fill=(231, 76, 60, 255), outline=(150, 30, 20, 255))
    d.ellipse([4, 10, 8, 22], fill=(78, 42, 20, 255), outline=(150, 30, 20, 255))
    # Handle on top
    d.arc([10, 5, 18, 13], 180, 360, fill=(192, 57, 43, 255), width=2)
    # Big coffee puddle
    d.ellipse([16, 16, 50, 24], fill=(85, 45, 22, 240), outline=(50, 25, 10, 255))
    d.ellipse([26, 18, 46, 23], fill=(110, 60, 30, 255)) # highlight puddle
    # Drops
    d.rectangle([51, 19, 53, 21], fill=(85, 45, 22, 255))
    img.save("coffee_spill.png")

def create_alarm_lamp():
    # Siren light 28x22
    img = Image.new("RGBA", (30, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Base ceiling mount
    d.rectangle([4, 0, 26, 5], fill=(70, 75, 80, 255), outline=(30, 32, 35, 255))
    # Red glass dome hanging down
    d.pieslice([6, 4, 24, 22], 0, 180, fill=(231, 76, 60, 255), outline=(160, 20, 20, 255))
    # Light glare
    d.line([10, 8, 12, 14], fill=(255, 180, 180, 220), width=2)
    img.save("alarm_siren.png")

def create_explosion_smoke():
    # Explosion puff 64x64
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Puffy smoke clouds
    d.ellipse([10, 14, 40, 44], fill=(130, 135, 145, 230))
    d.ellipse([24, 8, 54, 38], fill=(170, 175, 185, 240))
    d.ellipse([20, 24, 58, 56], fill=(110, 115, 125, 220))
    d.ellipse([14, 32, 38, 58], fill=(90, 95, 105, 210))
    # Fire/Spark core in center
    d.ellipse([26, 22, 42, 38], fill=(255, 140, 20, 255))
    d.ellipse([30, 26, 38, 34], fill=(255, 240, 80, 255))
    img.save("explosion_puff.png")

if __name__ == "__main__":
    create_lab_desk()
    create_pc_screens()
    create_keyboard()
    create_coffee_mug()
    create_coffee_spill()
    create_alarm_lamp()
    create_explosion_smoke()
    print("Art generated successfully!")
