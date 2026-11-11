"""The vendored map is a reproducible transformation of its source data."""
import json
import unittest
from pathlib import Path

from tools.build_map_data import build


class MapDataTests(unittest.TestCase):
    def test_rebuild_matches_committed_data(self):
        path = Path(__file__).resolve().parent.parent / "data" / "map" / "world_110m.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        self.assertEqual(build(), data)
        self.assertGreaterEqual(len(data["countries"]), 170)
        self.assertGreaterEqual(len(data["cities"]), 200)
        self.assertEqual(len({country["id"] for country in data["countries"]}), len(data["countries"]))


if __name__ == "__main__":
    unittest.main()
