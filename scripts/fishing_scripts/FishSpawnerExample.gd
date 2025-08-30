extends Node2D

# Example script showing how to use the enhanced FishSpawner
# This script demonstrates various ways to control fish spawning

@export var fish_spawner: FishSpawner

func _ready():
	if fish_spawner:
		# Print information about available fish types
		print(fish_spawner.get_fish_types_info())
		print("Total fish types: ", fish_spawner.get_fish_types_count())

func _input(event):
	if event.is_action_pressed("ui_accept"):  # Spacebar
		# Spawn 5 random fish
		if fish_spawner:
			fish_spawner.spawn_fish(5)
			print("Spawned 5 random fish!")
	
	elif event.is_action_pressed("ui_cancel"):  # Escape
		# Clear all fish
		if fish_spawner:
			fish_spawner.clear_all_fish()
			print("Cleared all fish!")
	
	elif event.is_action_pressed("ui_focus_next"):  # Tab
		# Print current fish count
		if fish_spawner:
			print("Current fish count: ", fish_spawner.current_fish_count)

# Example of how to spawn specific fish types programmatically
func spawn_specific_fish_example():
	if fish_spawner and fish_spawner.fish_scenes.size() > 0:
		# Spawn 3 of the first fish type
		var first_fish_type = fish_spawner.fish_scenes[0]
		fish_spawner.spawn_specific_fish(first_fish_type, 3)
		print("Spawned 3 specific fish!")

# Example of how to check if a fish type is available
func check_fish_type_availability():
	if fish_spawner and fish_spawner.fish_scenes.size() > 0:
		var first_fish_type = fish_spawner.fish_scenes[0]
		if fish_spawner.has_fish_type(first_fish_type):
			print("First fish type is available!")
		else:
			print("First fish type is not available!")
