extends Control

func _ready():
	# Set up the pause menu to know which scene it came from
	
	# Ensure this control can receive input events
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Make sure input events are processed
	set_process_input(true)
	
	print("Debug scene controller ready")
	
	# Debug scene tree structure (temporarily disabled to prevent crashes)
	# print("Scene tree structure:")
	# _print_scene_tree_safe(self, 0)

func _print_scene_tree_safe(node: Node, depth: int):
	if not node:
		return
	var indent = "  "
	var node_name = node.name if node.name else "unnamed"
	var node_class = node.get_class() if node.has_method("get_class") else "unknown"
	print(indent + "- " + node_name + " (" + node_class + ")")
	
	# Safely get children
	var children = node.get_children()
	if children:
		for child in children:
			if child:
				_print_scene_tree_safe(child, depth + 1)

func _input(event):
	print("Debug scene controller received input: ", event)
	
	# Debug all key presses
	if event is InputEventKey and event.pressed:
		print("Key pressed: ", event.keycode, " (ESC = 4194305, P = 80)")
		# Check if ESC action is detected
		if event.is_action_pressed("ui_cancel"):
			print("ESC action detected!")
		else:
			print("ESC action NOT detected for keycode: ", event.keycode)

func transition_to_level():
	# Get the current level from globals
	var current_level = Globals.current_level
	print("Transitioning to level: ", current_level)
	
	# Define the scene paths for each level
	var level_scenes = {
		"ice": "res://scenes/levels/ice.tscn",
		"beach": "res://scenes/levels/beach.tscn",
		"coral": "res://scenes/levels/coral.tscn",
		"volcano": "res://scenes/levels/volcano.tscn",
		"abyss": "res://scenes/levels/abyss.tscn"
	}
	
	# Check if the current level exists in our mapping
	if level_scenes.has(current_level):
		var scene_path = level_scenes[current_level]
		print("Loading scene: ", scene_path)
		
		# Change to the scene
		get_tree().change_scene_to_file(scene_path)
	else:
		print("Unknown level: ", current_level)
		print("Available levels: ", level_scenes.keys())

