extends Control

func _ready():
	# Set up the pause menu to know which scene it came from
	var pause_menu = $PauseMenu
	if pause_menu:
		pause_menu.set_game_scene("res://scenes/game.tscn")
	
	# Set up the fishing scene
	var fishing_scene = $FishingScene
	if fishing_scene:
		# Any additional setup for the fishing scene can go here
		pass
