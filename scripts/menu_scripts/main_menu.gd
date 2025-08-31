extends Control

@export var click_delay: float = 0.35                   # how long to wait before scene change
@export var click_player_path: NodePath                 # (optional) AudioStreamPlayer for the click sound

@onready var _btn_container: VBoxContainer = $VBoxContainer
@onready var _click_player: AudioStreamPlayer = get_node_or_null(click_player_path) as AudioStreamPlayer

var _transitioning := false

func _ready():
	# Connect button signals
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/EventsButton.pressed.connect(_on_events_pressed)
	$VBoxContainer/DebugButton.pressed.connect(_on_debug_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)

func _on_start_pressed() -> void:
	_go("res://scenes/map.tscn")

func _on_events_pressed() -> void:
	_go("res://scenes/Events_scene/events.tscn")

func _on_debug_pressed() -> void:
	_go("res://scenes/fishing_scene/debug_scene.tscn")

func _on_settings_pressed() -> void:
	_go("res://scenes/settings.tscn")

func _on_exit_pressed() -> void:
	if _transitioning: return
	_transitioning = true
	if _click_player: _click_player.play()
	await get_tree().create_timer(click_delay).timeout
	get_tree().quit()

# --- Helpers ---
func _go(path: String) -> void:
	if _transitioning:
		return
	_transitioning = true
	_set_buttons_enabled(false)

	# Play click sound if provided
	if _click_player:
		_click_player.play()

	# Wait a little so the sound is heard
	await get_tree().create_timer(click_delay).timeout

	get_tree().change_scene_to_file(path)

func _set_buttons_enabled(enabled: bool) -> void:
	for child in _btn_container.get_children():
		if child is BaseButton:
			(child as BaseButton).disabled = not enabled
