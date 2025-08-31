extends Node2D

@export var search_roots: Array[Node]
@export var beach_path: String = "res://scenes/levels/beach.tscn"
@export var ice_path: String = "res://scenes/levels/ice.tscn"
@export var volcano_path: String = "res://scenes/levels/volcano.tscn"
@export var coral_path: String = "res://scenes/levels/coral.tscn"
@export var abyss_path: String = "res://scenes/levels/abyss.tscn"

var eventNames: Array[String] = [
	"The Downwind",
	"The Payment",
	"The Shoal",
	"The Storm",
	"The Strong Tide",
	"The Treasure"
]

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

	var pool: Array[String] = eventNames.duplicate()
	pool.shuffle()

	var count: int = min(search_roots.size(), pool.size())
	for i in range(count):
		var root: Node = search_roots[i] if search_roots[i] else self
		var event_name: String = pool[i]
		_assign_event_to_root(root, event_name)

	if search_roots.size() > pool.size():
		push_warning("More roots than available events; extra roots were not assigned.")

func _assign_event_to_root(root: Node, event_name: String) -> void:
	# 1) Immediately fill the UI under this root
	var panel: EventPanel = _find_event_panel(root)
	if panel:
		var ok := panel.show_event(event_name)
		if not ok:
			push_warning("Panel under %s could not show event '%s'." % [root.name, event_name])
	else:
		push_warning("EventPanel not found under %s" % root.name)

	# 2) (Optional) Also hook the SailButton to change scene using this assigned event
	var button: BaseButton = root.find_child("SailButton", true, false) as BaseButton
	if button:
		if not button.pressed.is_connected(Callable(self, "_on_sail_button_pressed")):
			# capture event_name for this specific root
			button.pressed.connect(func():
				Globals.current_event = event_name
				_on_sail_button_pressed()
			)
	else:
		push_warning("SailButton not found under %s" % root.name)

func _find_event_panel(n: Node) -> EventPanel:
	# Depth-first search for a node of type EventPanel inside 'n'
	var p: EventPanel = n as EventPanel
	if p: 
		return p
	for child in n.get_children():
		var found := _find_event_panel(child)
		if found:
			return found
	return null

func _on_sail_button_pressed() -> void:
	var lvl := Globals.current_level
	var lvl_path : String
	match lvl:
		"beach":
			lvl_path = beach_path
			print("Level is beach")
			# do beach-specific logic here
		"ice":
			lvl_path = ice_path
			print("Level is ice")
			# do ice-specific logic here
		"volcano":
			lvl_path = volcano_path
			print("Level is volcano")
			# do volcano-specific logic here
		"coral":
			lvl_path = coral_path
			print("Level is coral")
			# do coral-specific logic here
		"abyss":
			lvl_path = abyss_path
			print("Level is abyss")
			# do abyss-specific logic here
		_:
			lvl_path = beach_path
			print("Unknown level:", lvl)
	print("Loading:", lvl_path, " | Event:", Globals.current_event)
	get_tree().change_scene_to_file(lvl_path)
