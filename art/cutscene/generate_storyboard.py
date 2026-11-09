from PIL import Image, ImageDraw, ImageFont

# Canvas 1280x720 (4 panels of 640x360)
grid = Image.new("RGBA", (1280, 720), (20, 24, 35, 255))

bg = Image.open('panico-no-laboratorio/art/environment/display_lab_background_clean.png').resize((688, 384))
floor_tile = Image.open('panico-no-laboratorio/art/environment/lab_floor_tile_128.png')
desk = Image.open('panico-no-laboratorio/art/cutscene/lab_desk.png')
kb = Image.open('panico-no-laboratorio/art/cutscene/keyboard.png')
siren = Image.open('panico-no-laboratorio/art/cutscene/alarm_siren.png')

screen_work = Image.open('panico-no-laboratorio/art/cutscene/screen_working.png')
screen_glitch = Image.open('panico-no-laboratorio/art/cutscene/screen_glitch.png')
screen_alert = Image.open('panico-no-laboratorio/art/cutscene/screen_alert.png')

mug_up = Image.open('panico-no-laboratorio/art/cutscene/coffee_mug_up.png')
mug_spill = Image.open('panico-no-laboratorio/art/cutscene/coffee_spill.png')
smoke = Image.open('panico-no-laboratorio/art/cutscene/explosion_puff.png')

p_stand = Image.open('panico-no-laboratorio/art/player/PNG/Player/Poses/player_stand.png')
p_hurt = Image.open('panico-no-laboratorio/art/player/PNG/Player/Poses/player_hurt.png')
p_walk1 = Image.open('panico-no-laboratorio/art/player/PNG/Player/Poses/player_walk1.png')

def resize_p(img):
    return img.resize((int(img.width * 0.5), int(img.height * 0.5)))

p_stand = resize_p(p_stand)
p_hurt = resize_p(p_hurt)
p_walk1 = resize_p(p_walk1)

def draw_base_panel():
    p = Image.new("RGBA", (640, 360))
    p.paste(bg, (0, -12))
    for x in range(0, 640, 128):
        p.paste(floor_tile, (x, 275))
    p.paste(desk, (300, 220), desk)
    p.paste(kb, (320, 225), kb)
    p.paste(siren, (305, 0), siren)
    return p

# Panel 1: Working peacefully
p1 = draw_base_panel()
p1.paste(screen_work, (340, 168), screen_work)
p1.paste(mug_up, (305, 218), mug_up)
p1.paste(p_stand, (240, 275 - p_stand.height), p_stand)
d1 = ImageDraw.Draw(p1)
d1.rectangle([60, 295, 580, 345], fill=(15, 20, 30, 220), outline=(100, 100, 120))
d1.text((75, 305), "1. Tranquilidade: '99% do relatorio pronto! So mais um cafe...'", fill=(255, 255, 255))

# Panel 2: Coffee spilled on keyboard
p2 = draw_base_panel()
p2.paste(screen_glitch, (340, 168), screen_glitch)
p2.paste(mug_spill, (310, 222), mug_spill)
p2.paste(p_hurt, (240, 275 - p_hurt.height), p_hurt)
d2 = ImageDraw.Draw(p2)
d2.rectangle([60, 295, 580, 345], fill=(15, 20, 30, 220), outline=(220, 150, 40))
d2.text((75, 305), "2. Desastre: Caneca tomba no teclado! Curto-circuito elétrico!", fill=(255, 220, 100))

# Panel 3: Explosion
p3 = draw_base_panel()
p3.paste(screen_alert, (340, 168), screen_alert)
p3.paste(mug_spill, (310, 222), mug_spill)
p3.paste(smoke, (340, 150), smoke)
p3.paste(p_hurt, (220, 275 - p_hurt.height), p_hurt)
d3 = ImageDraw.Draw(p3)
d3.rectangle([60, 295, 580, 345], fill=(50, 10, 10, 230), outline=(255, 50, 50))
d3.text((75, 305), "3. BOOM!! Computador estoura e apaga!", fill=(255, 100, 100))

# Panel 4: Emergency Alarm & Run
p4 = draw_base_panel()
red_ov = Image.new("RGBA", (640, 360), (255, 0, 0, 80))
p4 = Image.alpha_composite(p4, red_ov)
p4.paste(screen_alert, (340, 168), screen_alert)
p4.paste(p_walk1, (420, 275 - p_walk1.height), p_walk1)
d4 = ImageDraw.Draw(p4)
d4.rectangle([40, 50, 600, 120], fill=(20, 0, 0, 240), outline=(255, 0, 0), width=2)
d4.text((70, 65), "ALARME: SERVIDOR PRESERVA DADOS NO FINAL DO LAB!", fill=(255, 50, 50))
d4.text((120, 85), "LABORATORIO FECHA EM 60 SEGUNDOS! CORRA!!", fill=(255, 220, 0))
d4.rectangle([60, 295, 580, 345], fill=(15, 20, 30, 220), outline=(100, 200, 255))
d4.text((75, 305), "4. Fuga: 'PRECISO CORRER ATE O SERVIDOR AGORA MESMO!!'", fill=(255, 255, 255))

# Paste to grid
grid.paste(p1, (0, 0))
grid.paste(p2, (640, 0))
grid.paste(p3, (0, 360))
grid.paste(p4, (640, 360))

grid.save('panico-no-laboratorio/art/cutscene/storyboard_preview.png')
print("Storyboard saved successfully!")
