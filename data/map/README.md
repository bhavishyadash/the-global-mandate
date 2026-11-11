# Prototype world map data

The offline map uses Natural Earth 1:110m admin-0 country polygons and populated places. Natural Earth states its published vector and raster data are in the public domain: <https://www.naturalearthdata.com/about/>. The two original GeoJSON files are checked in to keep this specific version reproducible:

- `natural_earth_countries_source.geojson`: <https://github.com/nvkelso/natural-earth-vector/blob/master/geojson/ne_110m_admin_0_countries.geojson> — SHA-256 `6866c877d39cba9c357620878839b336d569f8c662d3cfab4cb1dbe2d39c977f`
- `natural_earth_cities_source.geojson`: <https://github.com/nvkelso/natural-earth-vector/blob/master/geojson/ne_110m_populated_places_simple.geojson> — SHA-256 `0dbd25c9ad8bd797ddf164b067f563be5c16be2c002254eb594862377963f9dc`

The exact downloaded files, rather than the moving upstream `master` links, define the inputs. Run `python tools/build_map_data.py` to regenerate `world_110m.json`; a Python test compares the generated structure with the checked-in result. Coordinates are rounded to four decimal places. The compact file contains 177 admin-0 features and 243 populated-place points, not a complete list of all countries or cities. The dataset reflects Natural Earth's boundary and naming choices, which may omit or generalize small and disputed territories; it is not a definitive statement on sovereignty. See issue #115 for explicit disputed-boundary treatment.

The map uses an equirectangular projection and simplified 1:110m geometry. Polygon holes are considered during selection, but are not yet cut out of the rendered land fill. Extremely small or invalid-at-scale polygons may display only an outline. The USA feature can open an explicitly fictional sandbox, whose values are not real-world data. Other countries and all city markers are geographic reference data without their own playable simulation.
