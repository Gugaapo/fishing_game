extends Control

func _ready():
	# Set up the pause menu to know which scene it came from
	var pause_menu = $PauseMenu
	if pause_menu:
		pause_menu.set_game_scene("res://scenes/fishing_scene/debug_scene.tscn")
	
	# Ensure this control can receive input events
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Make sure input events are processed
	set_process_input(true)
	
	print("Debug scene controller ready")
	print("Pause menu found: ", pause_menu != null)
	
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
	
	# Forward input events to the pause menu if it exists
	var pause_menu = $PauseMenu
	if pause_menu and pause_menu.has_method("_input"):
		pause_menu._input(event)
	
	# Test with P key as well
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		print("P key pressed in debug scene controller")
		if pause_menu:
			pause_menu._input(event)
