from PIL import Image, ImageDraw, ImageFont

# Canvas 640x360
canvas = Image.new("RGBA", (640, 360), (30, 35, 50, 255))

# Draw lab background
bg = Image.open('panico-no-laboratorio/art/environment/display_lab_background_clean.png').resize((688, 384))
canvas.paste(bg, (0, -12))

# Floor
floor_tile = Image.open('panico-no-laboratorio/art/environment/lab_floor_tile_128.png')
for x in range(0, 640, 128):
    canvas.paste(floor_tile, (x, 275))

# PC at destination
pc = Image.open('panico-no-laboratorio/art/obstacles/goal_pc.png')
canvas.paste(pc, (450, 210), pc)

# Player stopped in front of PC
player = Image.open('panico-no-laboratorio/art/player/PNG/Player/Poses/player_stand.png')
p_w, p_h = int(player.width * 0.5), int(player.height * 0.5)
player = player.resize((p_w, p_h))
canvas.paste(player, (380, 275 - p_h), player)

# Dimmer overlay
dimmer = Image.new("RGBA", (640, 360), (0, 0, 0, 100))
canvas = Image.alpha_composite(canvas, dimmer)

# Draw Windows Save Dialog Panel (420x190) centered at (110, 85)
d = ImageDraw.Draw(canvas)
wx, wy, ww, wh = 110, 85, 420, 190

# Shadow
d.rectangle([wx+4, wy+4, wx+ww+4, wy+wh+4], fill=(0, 0, 0, 80))
# Body
d.rectangle([wx, wy, wx+ww, wy+wh], fill=(238, 238, 238, 255), outline=(60, 60, 60, 255))

# Title Bar
d.rectangle([wx+1, wy+1, wx+ww-1, wy+28], fill=(16, 80, 176, 255))
d.text((wx+10, wy+7), "Microsoft Word - Salvar Arquivo", fill=(255, 255, 255))
# [X] Button
d.rectangle([wx+ww-24, wy+4, wx+ww-4, wy+24], fill=(200, 50, 50, 255))
d.text((wx+ww-18, wy+6), "X", fill=(255, 255, 255))

# Icon
icon = Image.open('panico-no-laboratorio/art/ui/save_dialog_icon.png')
canvas.paste(icon, (wx+20, wy+45), icon)

# Text
d.text((wx+65, wy+45), "Deseja salvar as alteracoes feitas em:", fill=(30, 30, 30))
d.text((wx+65, wy+65), "\"Relatorio_Final_v2_DEFINITIVO.docx\"?", fill=(10, 10, 10))

# Warning
d.text((wx+65, wy+105), "AVISO: Restam apenas 14 segundos para salvar!", fill=(210, 20, 20))

# Buttons
# [Salvar]
d.rectangle([wx+60, wy+140, wx+150, wy+170], fill=(215, 230, 250), outline=(30, 110, 220), width=2)
d.text((wx+85, wy+148), "Salvar", fill=(0, 0, 0))

# [Nao Salvar]
d.rectangle([wx+170, wy+140, wx+270, wy+170], fill=(225, 225, 225), outline=(120, 120, 120))
d.text((wx+185, wy+148), "Nao Salvar", fill=(40, 40, 40))

# [Cancelar]
d.rectangle([wx+290, wy+140, wx+375, wy+170], fill=(225, 225, 225), outline=(120, 120, 120))
d.text((wx+305, wy+148), "Cancelar", fill=(40, 40, 40))

# Top HUD Time
d.text((20, 20), "TEMPO: 14", fill=(255, 255, 255))
d.text((500, 20), "PONTOS: 80", fill=(255, 255, 255))

canvas.save('panico-no-laboratorio/art/ui/preview_save_dialog.png')
print("Preview generated successfully!")
