extends Node2D

@onready var boat: Node2D = $boat
@export var boat_positions: Array[Vector2]
@export var event_scene_path: String = "res://scenes/Events_scene/events.tscn"

func _ready():
	# Hover connections
	$Interface/TextureRect/TutorialButton.mouse_entered.connect(func(): _on_button_hover(0))
	$Interface/TextureRect/IceButton.mouse_entered.connect(func(): _on_button_hover(1))
	$Interface/TextureRect/HeatButton.mouse_entered.connect(func(): _on_button_hover(2))
	$Interface/TextureRect/CoraisButton.mouse_entered.connect(func(): _on_button_hover(3))
	$Interface/TextureRect/AbyssButton.mouse_entered.connect(func(): _on_button_hover(4))

	# Click connections (each sends its key)
	_connect_click($Interface/TextureRect/TutorialButton, "tutorial")
	_connect_click($Interface/TextureRect/IceButton, "ice")
	_connect_click($Interface/TextureRect/HeatButton, "volcano")
	_connect_click($Interface/TextureRect/CoraisButton, "coral")
	_connect_click($Interface/TextureRect/AbyssButton, "abyss")

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
	Globals.current_level = key
	print("Loading:", event_scene_path, "| Level:", Globals.current_level)
	get_tree().change_scene_to_file(event_scene_path)
