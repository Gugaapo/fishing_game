extends Control

var game_scene: String = ""

func _ready():
	# Connect button signals
	$VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/ToMenuButton.pressed.connect(_on_to_menu_pressed)
	
	# Hide the pause menu initially
	visible = false
	
	# Process mode should be set to stop when paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Make sure the pause menu is on top
	z_index = 1000
	
	# Ensure the pause menu can receive input events
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	print("Pause menu initialized and ready")
	print("Pause menu process mode: ", process_mode)
	print("Pause menu mouse filter: ", mouse_filter)

func _input(event):
	print("Pause menu received input event: ", event)
	
	# Debug ESC action detection
	if event.is_action_pressed("ui_cancel"):
		print("ESC action detected in pause menu!")
		print("ESC key pressed, pause menu visible: ", visible)
		if visible:
			_resume_game()
		else:
			_pause_game()
	elif event.is_action_pressed("escape"):
		print("Escape action detected in pause menu!")
		print("Escape key pressed, pause menu visible: ", visible)
		if visible:
			_resume_game()
		else:
			_pause_game()
	# Handle P key as well
	elif event is InputEventKey and event.pressed and event.keycode == KEY_P:
		print("P key pressed, pause menu visible: ", visible)
		if visible:
			_resume_game()
		else:
			_pause_game()
	# Also check for ESC keycode directly
	elif event is InputEventKey and event.pressed and event.keycode == 4194305:
		print("ESC keycode detected directly in pause menu!")
		print("ESC key pressed, pause menu visible: ", visible)
		if visible:
			_resume_game()
		else:
			_pause_game()

func _unhandled_input(event):
	print("Pause menu received unhandled input event: ", event)
	if event.is_action_pressed("ui_cancel"): # ESC key
		print("ESC key pressed (unhandled), pause menu visible: ", visible)
		if visible:
			_resume_game()
		else:
			_pause_game()

func _pause_game():
	print("Pausing game...")
	print("Before pause - visible: ", visible, ", tree paused: ", get_tree().paused)
	visible = true
	get_tree().paused = true
	# Capture input when paused
	mouse_filter = Control.MOUSE_FILTER_STOP
	print("After pause - visible: ", visible, ", tree paused: ", get_tree().paused, ", mouse filter: ", mouse_filter)
	print("Game paused successfully")

func _resume_game():
	print("Resuming game...")
	visible = false
	get_tree().paused = false
	# Release input when resumed
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	print("Game resumed successfully")

func _on_resume_pressed():
	_resume_game()

func _on_settings_pressed():
	# Open settings and remember we came from pause menu
	var settings_scene = preload("res://scenes/settings.tscn")
	var settings_instance = settings_scene.instantiate()
	
	# Set the previous scene to the current game scene
	if game_scene != "":
		settings_instance.set_previous_scene(game_scene)
	else:
		settings_instance.set_previous_scene("res://scenes/pause_menu.tscn")
	
	# Add settings as child and show it
	add_child(settings_instance)
	settings_instance.visible = true

func _on_to_menu_pressed():
	# Unpause and go to main menu
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func set_game_scene(scene_path: String):
	game_scene = scene_path
