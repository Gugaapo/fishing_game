extends Control

func _ready():
	# Connect button signals
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/EventsButton.pressed.connect(_on_events_pressed)
	$VBoxContainer/DebugButton.pressed.connect(_on_debug_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)

func _on_start_pressed():
	# Change to events scene
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_events_pressed():
	# Change to events scene
	get_tree().change_scene_to_file("res://scenes/Events_scene/events.tscn")

func _on_debug_pressed():
	# Change to debug scene
	get_tree().change_scene_to_file("res://scenes/fishing_scene/debug_scene.tscn")

func _on_settings_pressed():
	# Change to settings scene
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_exit_pressed():
	# Exit the game
	get_tree().quit()
