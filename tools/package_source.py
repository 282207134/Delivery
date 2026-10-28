"""Create a portable source archive without build caches or machine settings."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

root = Path(__file__).resolve().parents[1]
target = root/'releases/DeliWell-source.zip'
target.parent.mkdir(exist_ok=True)
excluded_dirs = {'.dart_tool','.git','.idea','.gradle','build','build_temp','releases','__pycache__','ephemeral','.symlinks'}
excluded_files = {'local.properties','.flutter-plugins-dependencies','Generated.xcconfig','flutter_export_environment.sh','GeneratedPluginRegistrant.java','key.properties'}
with ZipFile(target,'w',ZIP_DEFLATED,compresslevel=6) as z:
    for file in sorted(root.rglob('*')):
        rel = file.relative_to(root)
        if not file.is_file() or any(part in excluded_dirs for part in rel.parts): continue
        if file.name in excluded_files or file.suffix in {'.log','.iml','.pyc'}: continue
        z.write(file, Path('DeliWell')/rel)
with ZipFile(target) as z:
    assert z.testzip() is None
    assert 'DeliWell/lib/main.dart' in z.namelist()
    assert 'DeliWell/README.md' in z.namelist()
print(f'{target.name}: {target.stat().st_size/1024/1024:.1f} MB')
