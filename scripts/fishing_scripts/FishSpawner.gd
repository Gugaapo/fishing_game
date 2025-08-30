extends Node2D

@export var fish_scenes: Array[PackedScene] = []  # Array of fish scenes to choose from randomly
@export var spawn_weights: Array = []      # Spawn weights for each fish type (higher = more common)
@export var count: int = 20                  # how many fish to spawn instantly
@export var area_size := Vector2(1000, 300)  # spawn area (W x H), centered on this node
@export var spawn_interval: float = 2.0      # seconds between spawns (0 = instant spawn)
@export var max_fish_count: int = 50         # maximum number of fish in the scene

var rng := RandomNumberGenerator.new()
var spawn_timer: float = 0.0
var current_fish_count: int = 0

func _ready():
	rng.randomize()
	if fish_scenes.is_empty():
		push_error("Assign fish scenes in the 'fish_scenes' array in the inspector.")
		return

	# Add this spawner to a group for easy access
	add_to_group("fish_spawner")

	if spawn_interval <= 0:
		# Instant spawn
		_spawn_fish_batch(count)
	else:
		# Spawn over time
		spawn_timer = spawn_interval

func _process(delta: float):
	if spawn_interval > 0 and current_fish_count < max_fish_count:
		spawn_timer -= delta
		if spawn_timer <= 0:
			_spawn_fish_batch(1)  # Spawn one fish at a time
			spawn_timer = spawn_interval

func _spawn_fish_batch(spawn_count: int):
	if fish_scenes.is_empty():
		return
		
	for i in range(spawn_count):
		if current_fish_count >= max_fish_count:
			break
			
		# Pick a random fish scene (with weights if available)
		var random_fish_scene: PackedScene
		if spawn_weights.size() == fish_scenes.size() and spawn_weights.size() > 0:
			random_fish_scene = _get_weighted_random_fish()
		else:
			random_fish_scene = fish_scenes[rng.randi() % fish_scenes.size()]
			
		var fish := random_fish_scene.instantiate() as FishBase
		
		if fish == null:
			push_warning("Failed to instantiate fish from scene: " + str(random_fish_scene.resource_path))
			continue
			
		add_child(fish)
		current_fish_count += 1
		
		# Add fish to a group for easy access
		fish.add_to_group("fish")

		# random position within the rectangle centered on this spawner
		var x = global_position.x - area_size.x * 0.5 + rng.randf() * area_size.x
		var y = global_position.y - area_size.y * 0.5 + rng.randf() * area_size.y
		fish.global_position = Vector2(x, y)
		
		# Connect to fish removal signal if it exists
		if fish.tree_exiting.is_connected(_on_fish_removed):
			fish.tree_exiting.disconnect(_on_fish_removed)
		fish.tree_exiting.connect(_on_fish_removed)

# Function to get a random fish scene based on weights
func _get_weighted_random_fish() -> PackedScene:
	var total_weight := 0.0
	for weight in spawn_weights:
		total_weight += weight
	
	var random_value := rng.randf() * total_weight
	var current_weight := 0.0
	
	for i in range(fish_scenes.size()):
		current_weight += spawn_weights[i]
		if random_value <= current_weight:
			return fish_scenes[i]
	
	# Fallback to last fish type
	return fish_scenes[-1]

func _on_fish_removed():
	current_fish_count -= 1
	if current_fish_count < 0:
		current_fish_count = 0
	print("Fish removed. Current count: %d" % current_fish_count)

# Function to manually spawn a specific number of fish
func spawn_fish(amount: int = 1):
	_spawn_fish_batch(amount)

# Function to manually spawn a specific fish type
func spawn_specific_fish(fish_scene: PackedScene, amount: int = 1):
	if fish_scene == null:
		return
		
	for i in range(amount):
		if current_fish_count >= max_fish_count:
			break
			
		var fish := fish_scene.instantiate() as FishBase
		if fish == null:
			push_warning("Failed to instantiate fish from scene: " + str(fish_scene.resource_path))
			continue
			
		add_child(fish)
		current_fish_count += 1
		
		# Add fish to a group for easy access
		fish.add_to_group("fish")

		# random position within the rectangle centered on this spawner
		var x = global_position.x - area_size.x * 0.5 + rng.randf() * area_size.x
		var y = global_position.y - area_size.y * 0.5 + rng.randf() * area_size.y
		fish.global_position = Vector2(x, y)
		
		# Connect to fish removal signal if it exists
		if fish.tree_exiting.is_connected(_on_fish_removed):
			fish.tree_exiting.disconnect(_on_fish_removed)
		fish.tree_exiting.connect(_on_fish_removed)

# Function to clear all fish
func clear_all_fish():
	for child in get_children():
		if child is FishBase:
			child.queue_free()
	current_fish_count = 0
	print("All fish cleared!")

# Function to get information about available fish types
func get_fish_types_info() -> String:
	var info := "Available fish types: "
	for i in range(fish_scenes.size()):
		var scene_name := fish_scenes[i].resource_path.get_file().get_basename()
		info += scene_name
		if i < fish_scenes.size() - 1:
			info += ", "
	return info

# Function to get the number of fish types available
func get_fish_types_count() -> int:
	return fish_scenes.size()

# Function to check if a specific fish type is available
func has_fish_type(fish_scene: PackedScene) -> bool:
	return fish_scenes.has(fish_scene)
