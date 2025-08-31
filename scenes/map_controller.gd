extends Node2D

@onready var boat: Node2D = $boat
@export var boat_positions: Array[Vector2]
@export var event_scene_path: String = "res://scenes/Events_scene/events.tscn"

# Fade settings
@export var fade_color: Color = Color.BLACK
@export var fade_duration: float = 0.6

var _is_transitioning := false
var _fade_layer: CanvasLayer
var _fade_rect: ColorRect

func _ready():
	# Hover connections
	$Interface/TextureRect/TutorialButton.mouse_entered.connect(func(): _on_button_hover(0))
	$Interface/TextureRect/IceButton.mouse_entered.connect(func(): _on_button_hover(1))
	$Interface/TextureRect/HeatButton.mouse_entered.connect(func(): _on_button_hover(2))
	$Interface/TextureRect/CoraisButton.mouse_entered.connect(func(): _on_button_hover(3))
	$Interface/TextureRect/AbyssButton.mouse_entered.connect(func(): _on_button_hover(4))

	# Click connections (each sends its key)
	_connect_click($Interface/TextureRect/TutorialButton, "beach")
	_connect_click($Interface/TextureRect/IceButton, "ice")
	_connect_click($Interface/TextureRect/HeatButton, "volcano")
	_connect_click($Interface/TextureRect/CoraisButton, "coral")
	_connect_click($Interface/TextureRect/AbyssButton, "abyss")

	# Create the fade overlay (starts invisible and NOT intercepting input)
	_create_fader()

func _on_button_hover(index: int) -> void:
	if index >= 0 and index < boat_positions.size():
		var tween := create_tween()
		tween.tween_property(boat, "position", boat_positions[index], 0.4)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _connect_click(ctrl: Control, key: String) -> void:
	ctrl.mouse_filter = Control.MOUSE_FILTER_STOP
	ctrl.gui_input.connect(_on_gui_click.bind(key))

func _on_gui_click(event: InputEvent, key: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_button_click(key)

func _on_button_click(key: String) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true

	Globals.current_level = key
	print("Loading:", event_scene_path, "| Level:", Globals.current_level)

	# Fade to black, then change scene
	_fade_and_change(event_scene_path)

# ---- Fade helpers ----
func _create_fader() -> void:
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100  # draw on top
	add_child(_fade_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(fade_color.r, fade_color.g, fade_color.b, 0.0) # fully transparent
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # do NOT block input while transparent
	_fade_rect.z_index = 1000

	# Fill entire viewport
	_fade_rect.anchor_left = 0.0
	_fade_rect.anchor_top = 0.0
	_fade_rect.anchor_right = 1.0
	_fade_rect.anchor_bottom = 1.0
	_fade_rect.offset_left = 0
	_fade_rect.offset_top = 0
	_fade_rect.offset_right = 0
	_fade_rect.offset_bottom = 0

	_fade_rect.visible = false  # start hidden so nothing looks off at load
	_fade_layer.add_child(_fade_rect)

func _fade_and_change(path: String) -> void:
	_fade_rect.visible = true
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP  # block clicks during fade

	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# animate the ColorRect's color alpha from 0 -> 1
	t.tween_property(
		_fade_rect,
		"color",
		Color(fade_color.r, fade_color.g, fade_color.b, 1.0),
		fade_duration
	)
	t.tween_callback(func(): get_tree().change_scene_to_file(path))
