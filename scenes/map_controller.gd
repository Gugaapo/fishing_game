extends Node2D

@onready var boat : Node2D = $boat 
@export var boat_positions: Array[Vector2]

func _ready():
	# connect hover signals
	$Interface/TextureRect/TutorialButton.mouse_entered.connect(func(): _on_button_hover(0))
	$Interface/TextureRect/IceButton.mouse_entered.connect(func(): _on_button_hover(1))
	$Interface/TextureRect/HeatButton.mouse_entered.connect(func(): _on_button_hover(2))
	$Interface/TextureRect/CoraisButton.mouse_entered.connect(func(): _on_button_hover(3))
	$Interface/TextureRect/AbyssButton.mouse_entered.connect(func(): _on_button_hover(4))
	
func _on_button_hover(index: int) -> void:
	if index >= 0 and index < boat_positions.size():
		# snap instantly
		# boat.position = boat_positions[index]
		
		# OR: slide smoothly with a tween
		var tween := create_tween()
		tween.tween_property(boat, "position", boat_positions[index], 0.4) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
