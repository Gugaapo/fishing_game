extends Node2D

@export var radius: float = 20.0
@export var speed: float = 100.0
@export var bottom_y: float = 420.0
@export var spawn_offset_y: float = 32.0
@export var player_path: NodePath
@export var spawn_local_position_path : NodePath
@export var rod_tip_path: NodePath
@export var rod_tip_local_offset := Vector2(0,0)
@export var line_color: Color = Color.WHITE
@export var line_width: float = 2.0

@export var catch_ui_control_path : NodePath
# Signal emitted when a fish is caught
signal fish_caught(fish_value: int, fish_name: String)

var going_down := false
var returning_up := false
var spawn_position: Vector2
var player: Node2D
var caught_fish: Array[Node] = []  # Array to hold multiple caught fish
var total_points: int = 0  # Track total points earned

@onready var hitbox: Area2D = $Hitbox
@onready var rod_tip_node: Node2D = get_node_or_null(rod_tip_path) as Node2D if rod_tip_path != NodePath() else null
@onready var spawn_local_position_node: Node2D = get_node_or_null(spawn_local_position_path)
@onready var catch_ui_control: CatchUIControl = get_node_or_null(catch_ui_control_path)

# preload the sounds
var catch_sounds := [
	#preload("res://assets/sounds/catch_fish_1.wav"),
	#preload("res://assets/sounds/catch_fish_2.wav")
]

@onready var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_to_group("fishing_rod")
	hide()

	# add the audio player to this node so it can play sounds
	add_child(audio_player)

	# Resolve player
	if player_path != NodePath():
		player = get_node_or_null(player_path) as Node2D
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Node2D
	
	# Make sure the hitbox radius matches the drawn circle
	var shape := hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape and shape.shape is CircleShape2D:
		(shape.shape as CircleShape2D).radius = radius


func _process(delta: float):
	if Input.is_action_just_pressed("fish") and not going_down and not returning_up:
		if player == null:
			push_warning("RedBall: Player not found.")
			return
		spawn_position = spawn_local_position_node.global_position
		global_position = spawn_position
		show()
		going_down = true

	if going_down:
		global_position.y += speed * delta
		if global_position.y >= bottom_y:
			going_down = false
			returning_up = true

	elif returning_up:
		global_position.y -= speed * delta
		if global_position.y <= spawn_position.y:
			returning_up = false
			hide()
			
			# Handle all caught fish
			if caught_fish.size() > 0:
				var total_caught_points = 0
				var caught_fish_names = []
				
				# Process each caught fish
				for fish in caught_fish:
					if fish and fish.is_inside_tree():
						var fish_value = 0
						var fish_name = fish.name
						
						# Get fish value
						if fish.has_method("on_caught"):
							fish_value = fish.on_caught()
						elif fish.has_method("get_value"):
							fish_value = fish.get_value()
						
						# Add to totals
						total_caught_points += fish_value
						caught_fish_names.append(fish_name)
						
						# Destroy the fish
						if fish.has_method("force_destroy"):
							fish.force_destroy()
						else:
							if fish.has_method("release"):
								fish.release()
							fish.queue_free()
							print("Destroying caught fish: %s" % fish.name)
				
				# Update total points and emit signal
				total_points += total_caught_points
				var fish_list = ", ".join(caught_fish_names)
				fish_caught.emit(total_caught_points, fish_list)
				print("Caught %d fish: %s! +%d points. Total: %d" % [caught_fish.size(), fish_list, total_caught_points, total_points])
				
				# Clear the caught fish array
				caught_fish.clear()
			
			# Removed automatic fleeing when no fish is caught
			# Fish will now only flee based on their individual lifetime timers

	queue_redraw()


func _draw():
	if not visible:
		return
	draw_circle(Vector2.ZERO, radius, Color.RED)
	var start_local := _get_rod_tip_local()
	var end_local := Vector2.ZERO
	if start_local != null:
		draw_line(start_local, end_local, line_color, line_width, true)


func _get_rod_tip_local() -> Vector2:
	if rod_tip_node:
		var tip_global := rod_tip_node.to_global(rod_tip_local_offset)
		return to_local(tip_global)
	return to_local(spawn_position)
	

# Called by a Fish when it collides with the ball
func on_hit_fish(fish: Node):
	if not visible:
		return
	
	# Check if the fish should be caught based on its catch chance
	if fish.has_method("should_be_caught") and fish.should_be_caught():
		# Fish was caught - add to caught fish array
		catch_ui_control.show_catch()
		going_down = false
		returning_up = true
		caught_fish.append(fish)  # Add fish to the array
		if fish.has_method("bite"):
			fish.bite(self)
		print("Fish %s successfully caught!" % fish.name)
	else:
		catch_ui_control.show_miss()
		# Fish escaped - make it flee to the sides
		if fish.has_method("escape_from_rod"):
			fish.escape_from_rod()
		elif fish.has_method("flee"):
			fish.flee()
		print("Fish %s escaped the hook!" % fish.name)

	# Play random catch sound
	#var random_index = randi() % catch_sounds.size()
	#audio_player.stream = catch_sounds[random_index]
	#audio_player.play()

# Function to get total points earned
func get_total_points() -> int:
	return total_points

# Function to reset total points
func reset_points():
	total_points = 0
	print("Points reset to 0")

# Function to add bonus points
func add_bonus_points(bonus: int):
	total_points += bonus
	print("Bonus points! +%d. Total: %d" % [bonus, total_points])

# Function to get number of currently caught fish
func get_caught_fish_count() -> int:
	return caught_fish.size()

# Function to get list of currently caught fish names
func get_caught_fish_names() -> Array[String]:
	var names: Array[String] = []
	for fish in caught_fish:
		if fish and fish.is_inside_tree():
			names.append(fish.name)
	return names

# Function to clear caught fish (useful for debugging or reset)
func clear_caught_fish():
	caught_fish.clear()
	print("Cleared caught fish array")

# Function to get fish catch chance information
func get_fish_catch_info(fish: Node) -> Dictionary:
	if fish and fish.has_method("get_value") and fish.has_method("should_be_caught"):
		return {
			"name": fish.name,
			"value": fish.get_value(),
			"catch_chance": fish.catch_chance if "catch_chance" in fish else 0.0,
			"lifetime": fish.lifetime if "lifetime" in fish else 0.0
		}
	return {}

# Function to display fish information (useful for debugging)
func display_fish_info(fish: Node):
	var info = get_fish_catch_info(fish)
	if info.size() > 0:
		print("Fish Info - Name: %s, Value: %d, Catch Chance: %.1f%%, Lifetime: %.1fs" % [
			info.name, info.value, info.catch_chance * 100, info.lifetime
		])

# Function to make all fish in the scene flee
func _make_all_fish_flee():
	var fish_spawner = get_tree().get_first_node_in_group("fish_spawner")
	if fish_spawner:
		# Find all fish children of the spawner
		for child in fish_spawner.get_children():
			if child is FishBase and child.has_method("flee"):
				child.flee()
		print("All fish are fleeing!")
	else:
		# Fallback: search for all fish in the scene
		var all_fish = get_tree().get_nodes_in_group("fish")
		for fish in all_fish:
			if fish is FishBase and fish.has_method("flee"):
				fish.flee()
		print("All fish are fleeing!")
