extends Node2D

@export var search_root: Node          # drag the nested scene root here
@export var scene_path: String = "res://scenes/fishing_scene/debug_scene.tscn"

func _ready():
	var root := search_root if search_root else self
	var button := root.find_child("SailButton", true, false) as BaseButton
	if button:
		button.pressed.connect(func(): _on_ui_button_pressed(scene_path))

func _on_ui_button_pressed(scene_path: String) -> void:
	print("Loading:", scene_path)
	get_tree().change_scene_to_file(scene_path)
