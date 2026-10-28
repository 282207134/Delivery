"""Build a portable Markdown page index and screenshot contact sheet."""
import json
import re
from pathlib import Path
from PIL import Image, ImageOps, ImageDraw, ImageFont

root = Path(__file__).resolve().parents[1]
design = json.loads((root/'docs/reference/design-content.json').read_text(encoding='utf-8'))
routes = ['/goods','/goods','/courier','/courier','/courier','/orders','/orders','/order','/order','/cart',
          '/profile','/user','/edit-profile','/cards','/add-card','/add-card','/favorites','/favorites','/favorites','/box',
          '/dish','/dish','/cafe','/supermarket','/market','/cafe','/cafes','/cafes','/home','/onboarding','/onboarding',
          '/onboarding','/sign-in','/sign-in','/verify','启动','/verify','/sign-up','/cafes','/cafes','/cafes']
out = ['# 页面与截图清单', '', '来源：Pixso `UI Kit_DeliWell` → `Page 1`；`Symbols` 为共享组件库，不作为独立业务页面。', '',
       '编号与原稿导出保持一致。空白/填写/展开/弹层是同一页面的不同状态；截图测试通过构造参数呈现状态，正常应用中通过按钮、输入和筛选操作进入。', '',
       '截图由 Android 模拟器中的 Flutter 渲染表面直接导出，不包含 Android 系统状态栏。截图不修改本地保存的数据。', '',
       '| 编号 | Pixso 原稿名称 | 原稿节点 | 页面路由 | 设计稿 | 运行截图 |', '| --- | --- | --- | --- | --- | --- |']
for i, item in enumerate(design):
    stem = Path(item['image']).stem
    shot = root/f'docs/screenshots/{stem}.png'
    out.append(f"| {i+1:02} | {item['frame']['name'].strip()} | `{item['frame']['id']}` | `{routes[i]}` | [原稿](reference/{item['image']}) | [截图](screenshots/{stem}.png) |")
out += ['', '## 补充页面', '', '| 页面 | 路由 | 截图 |', '| --- | --- | --- |']
for number, label, route in [(42,'历史订单','/orders'),(43,'地址编辑','/address'),(44,'优惠码','/promos'),(45,'设置','/settings'),(46,'帮助','/help'),(47,'商品列表','/products')]:
    path = next((root/'docs/screenshots').glob(f'{number:02}_*.png'))
    out.append(f'| {label} | `{route}` | [截图](screenshots/{path.name}) |')
out += ['', '## 长页面补充截图', '']
for path in sorted((root/'docs/screenshots').glob('*_scrolled.png')):
    out.append(f'- [{path.stem}](screenshots/{path.name})')
out += ['', '## 全部界面总览', '', '![界面总览](screenshots/overview.jpg)', '',
        '原稿节点与文字结构保存在 `reference/frames.json`、`reference/design-content.json`；素材节点保存在 `reference/assets.json`。',
        '未修改 Pixso 原文件。']
(root/'docs/页面清单.md').write_text('\n'.join(out)+'\n', encoding='utf-8')

shots = sorted(p for p in (root/'docs/screenshots').glob('*.png') if not p.stem.endswith('_scrolled'))
width, cell_h, columns = 190, 452, 6
sheet = Image.new('RGB', (columns*width, ((len(shots)+columns-1)//columns)*cell_h), '#eef1ed')
draw = ImageDraw.Draw(sheet)
font = ImageFont.truetype('C:/Windows/Fonts/arial.ttf', 11)
for i, path in enumerate(shots):
    x, y = (i % columns)*width, (i//columns)*cell_h
    im = ImageOps.contain(Image.open(path).convert('RGB'), (178,410))
    sheet.paste(im,(x+6,y+32))
    label = path.stem.replace('_',' ')
    draw.text((x+6,y+4),label[:27],font=font,fill='#384a4a')
    if len(label)>27: draw.text((x+6,y+17),label[27:54],font=font,fill='#384a4a')
sheet.save(root/'docs/screenshots/overview.jpg', quality=88)
assert len(design)==41 and len(shots)==47
print(f'Indexed {len(design)} reference states, {len(shots)} implemented states and 9 scrolled views.')
