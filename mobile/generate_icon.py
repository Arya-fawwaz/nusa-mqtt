from PIL import Image, ImageDraw

# Create a 512x512 image with a dark blue background
size = 512
img = Image.new('RGB', (size, size), color=(15, 46, 89)) # #0F2E59
draw = ImageDraw.Draw(img)

# Draw a lightning bolt
# Points for a lightning bolt
points = [
    (270, 80),
    (180, 260),
    (240, 260),
    (210, 430),
    (340, 210),
    (270, 210)
]
draw.polygon(points, fill=(255, 255, 255)) # White lightning bolt

# Save to assets
import os
os.makedirs('assets', exist_ok=True)
img.save('assets/icon.png')
print("Icon generated successfully at assets/icon.png")
