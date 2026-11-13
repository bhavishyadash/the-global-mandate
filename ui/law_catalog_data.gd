extends RefCounted

const PATH := "res://data/rules/law_catalog.json"
const HANDLERS := {"healthcare": "Healthcare", "procurement": "Finance", "test_budget_category": "Finance", "test_income_tax": "Tax", "test_corporate_tax": "Tax", "test_consumption_tax": "Tax"}

static func read() -> Variant:
	var file := FileAccess.open(PATH, FileAccess.READ)
	return JSON.parse_string(file.get_as_text()) if file != null else null

static func validate(data: Variant) -> String:
	if not data is Dictionary or data.size() != 3 or data.get("version") != 1 or not data.get("categories") is Array or not data.get("laws") is Array:
		return "Law catalogue is missing or has an invalid format."
	if data.categories.is_empty() or data.categories.size() > 32 or data.laws.size() > 500:
		return "Law catalogue is outside supported bounds."
	var categories := {}
	for category in data.categories:
		if not category is String or category.strip_edges() != category or category.is_empty() or category.length() > 40 or categories.has(category):
			return "Law catalogue contains an invalid or duplicate category."
		categories[category] = true
	var ids := {}
	for law in data.laws:
		if not law is Dictionary or law.size() != 4 or not law.get("id") is String or not law.get("name") is String or not law.get("category") is String or not law.get("keywords") is Array:
			return "Law catalogue contains an invalid law."
		if not categories.has(law.category) or ids.has(law.id) or (HANDLERS.has(law.id) and HANDLERS[law.id] != law.category) or (not HANDLERS.has(law.id) and not law.id.begins_with("topic_")) or law.id.length() > 160:
			return "Law catalogue contains an unknown, duplicate or mismatched handler."
		for character in law.id:
			if character not in "abcdefghijklmnopqrstuvwxyz0123456789_":
				return "Law catalogue contains an invalid identifier."
		if law.name.strip_edges() != law.name or law.name.is_empty() or law.name.length() > 80 or law.keywords.size() > 20:
			return "Law catalogue contains an invalid name or keywords."
		for word in law.keywords:
			if not word is String or word.strip_edges() != word or word.is_empty() or word.length() > 40:
				return "Law catalogue contains an invalid search keyword."
		ids[law.id] = true
	for id in HANDLERS:
		if not ids.has(id):
			return "Law catalogue does not include all implemented handlers."
	return ""
