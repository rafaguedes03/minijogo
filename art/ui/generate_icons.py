from PIL import Image, ImageDraw

def create_save_icon():
    # 32x32 classic floppy disk / word document icon
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Blue floppy disk body (classic Windows save icon)
    d.rectangle([3, 3, 28, 28], fill=(30, 90, 180, 255), outline=(15, 45, 95, 255))
    # Beveled cut corner top right
    d.polygon([(24, 3), (28, 7), (28, 3)], fill=(0, 0, 0, 0))
    d.line([(24, 3), (28, 7)], fill=(15, 45, 95, 255))
    
    # Metal shutter slider at top
    d.rectangle([8, 4, 21, 14], fill=(210, 215, 225, 255), outline=(120, 130, 145, 255))
    d.rectangle([11, 6, 14, 12], fill=(30, 90, 180, 255))
    
    # White paper label at bottom
    d.rectangle([7, 16, 24, 27], fill=(250, 250, 250, 255), outline=(160, 165, 175, 255))
    # Label lines
    d.line([9, 19, 22, 19], fill=(200, 30, 30, 255)) # Red header stripe
    d.line([9, 22, 20, 22], fill=(120, 130, 150, 255))
    d.line([9, 24, 18, 24], fill=(120, 130, 150, 255))
    
    img.save("save_dialog_icon.png")
    print("Icon generated successfully!")

if __name__ == "__main__":
    create_save_icon()
