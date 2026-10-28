"""Optimize exported Pixso artwork and prepare platform launcher icons.

Authoring tool only: pip install pillow fonttools
Original node IDs are retained in docs/reference/assets.json.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
images = ROOT / 'assets/images'
for source in images.glob('*.png'):
    im = Image.open(source)
    im.thumbnail((1400, 1600), Image.Resampling.LANCZOS)
    im.save(source.with_suffix('.webp'), quality=88, method=6,
            lossless=source.stem.startswith(('logo', 'pattern')))

def icon(size, path):
    im = Image.new('RGB', (size, size), '#80AA85')
    draw = ImageDraw.Draw(im)
    font = ImageFont.truetype(str(ROOT / 'assets/fonts/Yrsa-Medium.ttf'), int(size*.8))
    box = draw.textbbox((0,0), 'D', font=font)
    draw.text(((size-(box[2]-box[0]))/2-box[0], (size-(box[3]-box[1]))/2-box[1]), 'D', font=font, fill='#F1F5F1')
    r = max(2, int(size*.055))
    draw.ellipse((size*.73-r,size*.28-r,size*.73+r,size*.28+r), fill='#FFD374')
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path)

for density, size in [('mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]:
    icon(size, ROOT / f'android/app/src/main/res/mipmap-{density}/ic_launcher.png')
for path in (ROOT / 'ios/Runner/Assets.xcassets/AppIcon.appiconset').glob('*.png'):
    icon(Image.open(path).width, path)
for path in (ROOT / 'web/icons').glob('*.png'):
    icon(Image.open(path).width, path)
icon(32, ROOT/'web/favicon.png')
