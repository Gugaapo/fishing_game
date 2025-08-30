extends Node2D

# Example script showing how to use the fish value system
# This script demonstrates how to track points and respond to fish catches

@export var fishing_rod: Node2D

func _ready():
	if fishing_rod and fishing_rod.has_method("fish_caught"):
		# Connect to the fish_caught signal
		fishing_rod.fish_caught.connect(_on_fish_caught)
		print("Connected to fishing rod fish_caught signal!")
	else:
		push_warning("Fishing rod not assigned or invalid!")

# Called when a fish is caught
func _on_fish_caught(fish_value: int, fish_names: String):
	print("🎣 Fish caught: %s worth %d points!" % [fish_names, fish_value])
	
	# You can add UI updates, sound effects, or other game logic here
	# For example:
	# - Update score display
	# - Play catch sound
	# - Show catch animation
	# - Update achievements

# Function to get current total points
func get_current_score() -> int:
	if fishing_rod and fishing_rod.has_method("get_total_points"):
		return fishing_rod.get_total_points()
	return 0

# Function to reset the score
func reset_score():
	if fishing_rod and fishing_rod.has_method("reset_points"):
		fishing_rod.reset_points()
		print("Score reset!")

# Function to add bonus points
func add_bonus(bonus_amount: int):
	if fishing_rod and fishing_rod.has_method("add_bonus_points"):
		fishing_rod.add_bonus_points(bonus_amount)

# Function to get current caught fish information
func get_caught_fish_info():
	if fishing_rod and fishing_rod.has_method("get_caught_fish_count"):
		var count = fishing_rod.get_caught_fish_count()
		var names = fishing_rod.get_caught_fish_names()
		print("Currently caught fish: %d - %s" % [count, ", ".join(names)])
		return {"count": count, "names": names}
	return {"count": 0, "names": []}

# Function to display fish catch statistics
func display_fish_stats():
	if fishing_rod and fishing_rod.has_method("get_total_points"):
		var total_points = fishing_rod.get_total_points()
		var caught_count = get_caught_fish_info()["count"]
		print("=== Fishing Statistics ===")
		print("Total Points: %d" % total_points)
		print("Currently Caught: %d fish" % caught_count)
		print("========================")

# Function to get fish information (if you have a reference to a fish)
func get_fish_info(fish: Node):
	if fishing_rod and fishing_rod.has_method("display_fish_info"):
		fishing_rod.display_fish_info(fish)

# Function to display fish speed information
func display_fish_speed(fish: Node):
	if fish and fish.has_method("get_current_speed"):
		var current_speed = fish.get_current_speed()
		var base_speed = fish.speed if "speed" in fish else 0
		var speed_multiplier = fish.escaped_speed_multiplier if "escaped_speed_multiplier" in fish else 1.0
		var has_escaped = fish.has_escaped_from_rod() if fish.has_method("has_escaped_from_rod") else false
		
		print("Fish %s - Base Speed: %.1f, Current Speed: %.1f" % [fish.name, base_speed, current_speed])
		if has_escaped:
			print("  -> Escaped fish moving at %.1fx speed!" % speed_multiplier)

# Example of how to display score in UI
func update_score_display():
	var current_score = get_current_score()
	print("Current Score: %d points" % current_score)
	# You would typically update a UI label here
	# score_label.text = str(current_score) 