# Globals.gd
extends Node

var money: int = 0
var current_level: String = ""
var current_event: String = ""

func save() -> void:
	var data := {
		"money": money,
		"current_level" : "tutorial",
		"current_event": "none"
	}
	var f := FileAccess.open("user://savegame.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(data))
	f.close()

func load() -> bool:
	if not FileAccess.file_exists("user://savegame.json"):
		return false
	var f := FileAccess.open("user://savegame.json", FileAccess.READ)
	var text := f.get_as_text()
	f.close()
	var parsed : Dictionary = JSON.parse_string(text)
	if typeof(parsed) == TYPE_DICTIONARY:
		money = parsed.get("score", 0)
		current_level = parsed.get("current_level", "")
		current_event = parsed.get("current_event", [])
		return true
	return false
