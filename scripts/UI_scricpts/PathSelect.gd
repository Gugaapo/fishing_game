extends Control

func _ready():
	# Connect button signals
	$VBoxContainer/ButtonPath1.pressed.connect(on_path1)
	$VBoxContainer/ButtonPath2.pressed.connect(on_path2)
	$VBoxContainer/ButtonPath3.pressed.connect(on_path3)


func on_path1():
	print("Player chose Path 1")
	_load_next_scene("Path 1")

func on_path2():
	print("Player chose Path 2")
	_load_next_scene("Path 2")

func on_path3():
	print("Player chose Path 3")
	_load_next_scene("Path 3")


func _load_next_scene(path_name: String):
	# For now, just load the same scene (replace with your target scene later)
	var scene = preload("res://scenes/guilherme-tutorial/debug_scene.tscn").instantiate()
	get_tree().change_scene_to_packed(scene)

	# Debug: we could also pass the choice along
	print("Loading scene for: ", path_name)
