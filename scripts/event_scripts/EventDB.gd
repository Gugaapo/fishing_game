# EventDB.gd (autoload)
extends Node

const EVENTS_DIR := "res://events_data"  # <-- set to your actual folder

var events: Dictionary = {}          # exact name -> EventData
var _name_lut: Dictionary = {}       # lowercase -> exact name
var _loaded := false

func _ready() -> void:
	_load_events()

func _ensure_loaded() -> void:
	if not _loaded:
		_load_events()

func _load_events() -> void:
	events.clear()
	_name_lut.clear()
	_loaded = false

	var dir := DirAccess.open(EVENTS_DIR)
	if dir == null:
		push_error("EventDB: can't open dir: %s" % EVENTS_DIR)
		return

	dir.list_dir_begin()
	var fname := dir.get_next()
	var count := 0
	while fname != "":
		if not dir.current_is_dir() and fname.ends_with(".tres"):
			var path := EVENTS_DIR.path_join(fname)
			var res := ResourceLoader.load(path, "EventData")  # type hint helps if class_name EventData exists
			if res == null:
				res = ResourceLoader.load(path)

			if res is EventData:
				var key := String(res.name).strip_edges()
				if key.is_empty():
					key = fname.get_basename()
				events[key] = res
				_name_lut[key.to_lower()] = key
				count += 1
			else:
				var type_name := "null"
				if res != null:
					type_name = res.get_class()
				push_warning("EventDB: skipping %s (type: %s)" % [fname, type_name])
		fname = dir.get_next()
	dir.list_dir_end()

	_loaded = true
	print("EventDB: loaded %d events from %s" % [count, EVENTS_DIR])
	if count > 0:
		print("EventDB keys:", events.keys())

func get_event(name: String) -> EventData:
	_ensure_loaded()
	if events.has(name):
		return events[name]
	var lc := name.to_lower()
	if _name_lut.has(lc):
		return events[_name_lut[lc]]
	return null

func list_event_names() -> PackedStringArray:
	_ensure_loaded()
	return PackedStringArray(events.keys())
