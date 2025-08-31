extends Control

var previous_scene: String = ""

func _ready():
	# Connect button signals
	$VBoxContainer/ControlsButton.pressed.connect(_on_controls_pressed)
	$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	
	# Connect slider signals
	$VBoxContainer/MusicVolumeSlider.value_changed.connect(_on_music_volume_changed)
	$VBoxContainer/SFXVolumeSlider.value_changed.connect(_on_sfx_volume_changed)
	
	# Load current volume settings
	_load_volume_settings()

func _load_volume_settings():
	# Load saved volume settings (you can implement this with ConfigFile later)
	var music_volume = 50.0
	var sfx_volume = 50.0
	
	$VBoxContainer/MusicVolumeSlider.value = music_volume
	$VBoxContainer/SFXVolumeSlider.value = sfx_volume

func _on_music_volume_changed(value: float):
	# Update music volume (implement with AudioServer later)
	print("Music volume changed to: ", value)

func _on_sfx_volume_changed(value: float):
	# Update SFX volume (implement with AudioServer later)
	print("SFX volume changed to: ", value)

func _on_controls_pressed():
	# Show controls popup or scene
	_show_controls()

func _on_back_pressed():
	# Go back to previous scene or main menu
	if previous_scene != "":
		get_tree().change_scene_to_file(previous_scene)
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _show_controls():
	# Create a simple controls popup
	var popup = AcceptDialog.new()
	popup.title = "Controls"
	popup.dialog_text = """
	Fishing Rod Controls:
	- Click to cast line
	- Hold to reel in
	
	Boat Movement:
	- Use arrow keys or WASD to move
	- Space to jump
	
	Menu Controls:
	- ESC to pause/open menu
	- Enter to confirm
	- Arrow keys to navigate
	"""
	popup.popup_centered()
	add_child(popup)
	
	# Auto-close after 5 seconds
	await get_tree().create_timer(5.0).timeout
	popup.queue_free()

func set_previous_scene(scene_path: String):
	previous_scene = scene_path
