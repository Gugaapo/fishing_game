extends Node

var events: Dictionary = {}
var _name_lut: Dictionary = {}
var _loaded: bool = false

@onready var _preloader: ResourcePreloader = get_node_or_null("Preloader") as ResourcePreloader

func _ready() -> void:
	_load_events()

func _load_events() -> void:
	events.clear()
	_name_lut.clear()
	_loaded = false

	if _preloader == null:
		push_error("EventDB: Preloader node not found. Make sure you autoload **EventDB.tscn** (a scene) whose root has this script and a child ResourcePreloader named 'Preloader'.")
		_loaded = true
		return

	var list: PackedStringArray = _preloader.get_resource_list()
	var i: int = 0
	var loaded_count: int = 0
	while i < list.size():
		var key_name: String = list[i]
		var res: Resource = _preloader.get_resource(key_name)
		if res is EventData:
			_register_event(res)
			loaded_count += 1
		else:
			var type_name: String = "null" if res == null else res.get_class()
			push_warning("EventDB: preloader entry '%s' is not EventData (type=%s)" % [key_name, type_name])
		i += 1

	_loaded = true
	print("EventDB: loaded %d events from preloader" % loaded_count)
	if loaded_count > 0:
		print("EventDB keys:", events.keys())

func _register_event(ev: EventData) -> void:
	var key: String = String(ev.name).strip_edges()
	if key.is_empty():
		var rp: String = ev.resource_path
		key = rp.get_file().get_basename()
	events[key] = ev
	_name_lut[key.to_lower()] = key

func get_event(name: String) -> EventData:
	if not _loaded:
		_load_events()
	if events.has(name):
		return events[name]
	var lc: String = name.to_lower()
	if _name_lut.has(lc):
		return events[_name_lut[lc]]
	return null

func list_event_names() -> PackedStringArray:
	if not _loaded:
		_load_events()
	return PackedStringArray(events.keys())
