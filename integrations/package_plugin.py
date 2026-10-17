"""Build a credential-free, reproducible Travel Crew plugin ZIP."""
import json
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "travelcrew-plugin"
manifest = json.loads((SOURCE / "plugin.json").read_text())
mcp = json.loads((SOURCE / "mcp.json").read_text())
assert manifest["name"] == "travelcrew"
assert mcp["mcpServers"] == {"travelcrew": {
    "type": "streamable-http", "url": "https://travelcrew.app/mcp"}}
interface = manifest["extensions"]["com.openai"]["interface"]
review = manifest["extensions"]["com.openai"]["review"]["test_cases"]
assert len(review["positive"]) == 5 and len(review["negative"]) == 3
assert len(interface["displayName"]) <= 30
assert len(interface["shortDescription"]) <= 30
files = {"plugin.json", "mcp.json"}
for key in ("composerIcon", "composerIconDark", "logo", "logoDark"):
    asset = (SOURCE / interface[key]).resolve()
    assert asset.is_relative_to(SOURCE.resolve()) and asset.is_file()
    files.add(asset.relative_to(SOURCE.resolve()).as_posix())
version = manifest["version"]
assert all(part.isdigit() for part in version.split("."))
destination = ROOT.parent / "build" / "integrations"
destination.mkdir(parents=True, exist_ok=True)
target = destination / f"travelcrew-plugin-{version}.zip"
with ZipFile(target, "w", compression=ZIP_DEFLATED) as archive:
    for name in sorted(files):
        info = ZipInfo(name, date_time=(2026, 10, 3, 0, 0, 0))
        info.compress_type = ZIP_DEFLATED
        info.external_attr = 0o644 << 16
        archive.writestr(info, (SOURCE / name).read_bytes())
with ZipFile(target) as archive:
    assert archive.testzip() is None
    assert set(archive.namelist()) == files
print(target)
print("Validated package contents: manifests, logo, five positive and three negative cases.")
