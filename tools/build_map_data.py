"""Convert the checked-in Natural Earth 1:110m GeoJSON to a compact map file."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MAP = ROOT / "data" / "map"


def point(position: list[float]) -> list[float]:
    lon, lat = position[:2]
    if not (-180 <= lon <= 180 and -90 <= lat <= 90):
        raise ValueError("Coordinate outside longitude/latitude bounds")
    return [round(lon, 4), round(lat, 4)]


def build() -> dict:
    countries = json.loads((MAP / "natural_earth_countries_source.geojson").read_text(encoding="utf-8"))
    cities = json.loads((MAP / "natural_earth_cities_source.geojson").read_text(encoding="utf-8"))
    result: dict = {"version": 1, "countries": [], "cities": []}
    ids: set[str] = set()
    for feature in countries["features"]:
        props, geom = feature["properties"], feature["geometry"]
        code = props["ADM0_A3"]
        if not code or code in ids:
            raise ValueError(f"Missing or duplicate country ID: {code}")
        ids.add(code)
        polygons = geom["coordinates"] if geom["type"] == "MultiPolygon" else [geom["coordinates"]]
        if geom["type"] not in ("Polygon", "MultiPolygon"):
            raise ValueError(f"Unsupported geometry: {geom['type']}")
        rings = [[[point(pos) for pos in ring] for ring in polygon] for polygon in polygons]
        result["countries"].append({"id": code, "name": props["NAME_EN"], "polygons": rings})
    for feature in cities["features"]:
        props, geom = feature["properties"], feature["geometry"]
        if geom["type"] != "Point" or not props.get("name"):
            raise ValueError("Invalid city")
        result["cities"].append({"name": props["name"], "country": props.get("adm0_a3", ""),
                                 "point": point(geom["coordinates"]), "capital": props.get("adm0cap") == 1,
                                 "major": props.get("pop_max", 0) >= 5000000})
    return result


if __name__ == "__main__":
    output = MAP / "world_110m.json"
    output.write_text(json.dumps(build(), ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")
    print(f"Wrote {output}")
