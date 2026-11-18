"""Configure mass-chaos. Run with no options to inspect the current settings."""
import argparse
import json
from pathlib import Path
import re

root = Path(__file__).resolve().parent
common = root / "Common.glsl"
config = root / "Image.sha.json"
source = common.read_text()
parser = argparse.ArgumentParser(description=__doc__)
for option, help_text in [
    ("substeps", "积分速率：每帧积分子步数"),
    ("grid", "分辨率：质量轴上每边的采样数"),
    ("max-mass", "质量上限：两条对数轴的最大质量"),
]:
    parser.add_argument("--" + option, type=int, help=help_text)
args = parser.parse_args()
settings = {}
for name, value, minimum in [
    ("SUBSTEPS", args.substeps, 1),
    ("GRID", args.grid, 2),
    ("MAX_MASS", args.max_mass, 2),
]:
    pattern = rf"(const int {name} = )(\d+);"
    match = re.search(pattern, source)
    if not match:
        parser.error(f"Common.glsl 缺少 {name}")
    value = int(match[2]) if value is None else value
    if value < minimum or value > 2147483647:
        parser.error(f"{name} 需要 {minimum} 到 2147483647 之间的整数")
    settings[name] = value
    source = re.sub(pattern, lambda m: f"{m[1]}{value};", source)

grid = settings["GRID"]
document = json.loads(config.read_text())
record = int(re.search(r"const int RECORD = (\d+);", source)[1])
if grid * grid * 3 + 3 > 2147483647:
    parser.error("网格超出四分位数统计的整数范围")
for name, width in [("BufferA", record * grid), ("BufferB", grid), ("BufferC", grid)]:
    document["passes"][name]["resolution"] = {"width": width, "height": grid}

if any(v is not None for v in vars(args).values()):
    for path, content in [(common, source), (config, json.dumps(document, indent=2) + "\n")]:
        if path.read_text() != content:
            tmp = path.with_suffix(path.suffix + ".tmp")
            tmp.write_text(content)
            tmp.replace(path)
print(f"每帧 {settings['SUBSTEPS']} 子步，网格 {grid} × {grid}，质量 1–{settings['MAX_MASS']}")
