extends Node2D
class_name FishBase

@export var bite_offset: Vector2 = Vector2(0, 0)
@export var speed: float = 120.0
@export var amplitude: float = 200.0
@export var start_moves_right: bool = true
@export var random_speed_range := Vector2(0.95, 1.10)
@export var head_offset_right: Vector2 = Vector2(18, 0)
@export var head_offset_left: Vector2 = Vector2(-18, 0)
@export var draw_hitbox: bool = false
@export var value: int = 10  # Points the player gets when fishing this fish
@export var lifetime: float = 30.0  # How long the fish stays on screen before fleeing (in seconds)
@export var catch_chance: float = 0.7  # Probability of being caught when hitting the rod (0.0 to 1.0)

const ROD_GROUP := "fishing_rod"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $AnimatedSprite2D/Hitbox

var biting := false
var target_rod: Node2D = null
var fleeing := false
var flee_target: Vector2
var flee_speed: float = 200.0
var lifetime_timer: float = 0.0
var has_escaped: bool = false  # Track if fish has escaped from fishing rod
var escaped_speed_multiplier: float = 2.0  # Speed multiplier for escaped fish
var rng := RandomNumberGenerator.new()
var dir := 1
var start_x := 0.0
var speed_scale := 1.0
var flee_timer: float = 0.0  # Timer for fleeing fish fade-out
var flee_duration: float = 3.0  # How long it takes for fish to fade out completely

func _ready():
	rng.randomize()
	dir = 1 if start_moves_right else -1
	speed_scale = rng.randf_range(random_speed_range.x, random_speed_range.y)
	start_x = global_position.x
	var phase_x := rng.randf_range(-amplitude, amplitude)
	global_position.x = start_x + phase_x
	
	# Initialize lifetime timer with some random variation (±20%)
	var lifetime_variation = rng.randf_range(0.8, 1.2)
	lifetime_timer = lifetime * lifetime_variation
	
	# Debug print to verify individual timers
	print("Fish %s spawned with lifetime: %.1f seconds" % [name, lifetime_timer])
	
	_apply_facing()
	if hitbox:
		hitbox.area_entered.connect(_on_hitbox_area_entered)
		_update_head_hitbox_offset()

func _process(delta: float):
	if fleeing:
		# Fish is fleeing directly to screen edge
		var viewport_size = get_viewport().get_visible_rect().size
		var target_x: float
		
		if dir < 0:  # Fleeing left
			target_x = -100.0  # Target position well off left side
		else:  # Fleeing right
			target_x = viewport_size.x + 100.0  # Target position well off right side
		
		# Move directly toward target
		var direction = 1 if target_x > global_position.x else -1
		global_position.x += flee_speed * direction * delta
		
		# Update flee timer for fade-out effect
		flee_timer += delta
		var fade_progress = flee_timer / flee_duration
		var opacity = 1.0 - fade_progress  # Start at 1.0, end at 0.0
		
		# Apply opacity to sprite
		if sprite:
			sprite.modulate.a = opacity
		
		# Debug: Print movement info occasionally for escaped fish
		if has_escaped and Engine.get_process_frames() % 120 == 0:  # Every 2 seconds
			print("Fish %s fleeing: pos=%.1f, target=%.1f, direction=%d, speed=%.1f, opacity=%.2f" % 
				[name, global_position.x, target_x, direction, flee_speed, opacity])
		
		# Destroy fish when opacity reaches 0 (completely transparent)
		if opacity <= 0.0:
			print("Fish %s faded out completely, destroying" % name)
			queue_free()  # Destroy the fish
			return
		
		# Check if fish hitbox has completely exited the camera view (backup destruction)
		var hitbox_global_pos = global_position + hitbox.position if hitbox else global_position
		var margin = 50.0
		
		if dir < 0:  # Fleeing left
			if hitbox_global_pos.x < -margin:
				print("Fish %s hitbox exited left side, destroying" % name)
				queue_free()  # Destroy the fish
		else:  # Fleeing right
			if hitbox_global_pos.x > viewport_size.x + margin:
				print("Fish %s hitbox exited right side, destroying" % name)
				queue_free()  # Destroy the fish
		return
	
	# Update lifetime timer (only when not biting or fleeing)
	if not biting and not fleeing:
		lifetime_timer -= delta
		if lifetime_timer <= 0:
			print("Fish %s lifetime expired, fleeing to side" % name)
			flee()  # Time's up, fish flees
			return
	
	if biting and is_instance_valid(target_rod):
		# Adjust bite offset and rotation based on fish direction
		var adjusted_bite_offset = bite_offset
		var adjusted_rotation = -PI / 2
		
		if dir < 0:  # Fish was moving left
			# Flip the bite offset horizontally and adjust rotation
			adjusted_bite_offset.x = -bite_offset.x
			adjusted_rotation = +PI / 2
		
		global_position = target_rod.global_position + adjusted_bite_offset
		rotation = adjusted_rotation
		return
	else:
		rotation = 0

	if amplitude > 0.0:
		# Apply speed multiplier if fish has escaped
		var current_speed = speed * speed_scale
		if has_escaped:
			current_speed *= escaped_speed_multiplier
		
		global_position.x += current_speed * dir * delta
		var dx := global_position.x - start_x
		if absf(dx) >= amplitude:
			global_position.x = start_x + signf(dx) * amplitude
			dir *= -1
			_apply_facing()
			_update_head_hitbox_offset()

	queue_redraw()

func _apply_facing():
	if sprite:
		sprite.flip_h = (dir > 0)

func _update_head_hitbox_offset():
	if hitbox:
		hitbox.position = head_offset_right if (dir >= 0) else head_offset_left

func _on_hitbox_area_entered(area: Area2D):
	# Don't allow escaped fish to be caught again
	if has_escaped:
		print("Fish %s has already escaped, ignoring collision (fleeing: %s)" % [name, fleeing])
		return
		
	var maybe_rod := area.get_parent()
	if maybe_rod and maybe_rod.is_in_group(ROD_GROUP):
		if maybe_rod.has_method("on_hit_fish"):
			maybe_rod.on_hit_fish(self)

func bite(rod: Node2D):
	if biting: return
	target_rod = rod
	biting = true

func release():
	biting = false
	target_rod = null
	rotation = 0
	# Don't reset fleeing state here, as fish might be fleeing due to lifetime

# Function to make the fish flee to the closest screen border
func flee():
	if fleeing:
		print("Fish %s is already fleeing, ignoring flee call" % name)
		return  # Already fleeing
		
	print("Fish %s starting to flee!" % name)
	fleeing = true
	biting = false
	target_rod = null
	rotation = 0
	
	# Reset flee timer and ensure sprite starts at full opacity
	flee_timer = 0.0
	if sprite:
		sprite.modulate.a = 1.0  # Start at full opacity
	
	# Set fleeing speed
	flee_speed = 300.0  # Faster fleeing speed
	
	# Calculate the closest side border (left or right only)
	var viewport_size = get_viewport().get_visible_rect().size
	var current_pos = global_position
	
	# Find the closest side border (left or right)
	var left_distance = current_pos.x
	var right_distance = viewport_size.x - current_pos.x
	
	# Set direction based on closest side
	if left_distance <= right_distance:
		# Flee left
		dir = -1
		_apply_facing_left()
		print("Fish %s fleeing LEFT to screen edge" % name)
	else:
		# Flee right
		dir = 1
		_apply_facing_right()
		print("Fish %s fleeing RIGHT to screen edge" % name)
	
	# Reset lifetime timer so fish doesn't get destroyed by lifetime while fleeing
	lifetime_timer = 999.0  # Give plenty of time to reach border

# Function to apply facing direction (left)
func _apply_facing_left():
	if sprite:
		sprite.flip_h = false

# Function to apply facing direction (right)
func _apply_facing_right():
	if sprite:
		sprite.flip_h = true

# Function to get the fish's value (points)
func get_value() -> int:
	return value

# Function called when fish is caught (can be overridden for special effects)
func on_caught() -> int:
	# Return the value and could add special effects here
	return value

# Function to get remaining lifetime
func get_remaining_lifetime() -> float:
	if fleeing:
		return 0.0
	return max(0.0, lifetime_timer)

# Function to get lifetime percentage (0.0 to 1.0)
func get_lifetime_percentage() -> float:
	if fleeing:
		return 0.0
	return max(0.0, lifetime_timer / lifetime)

# Function to check if fish is about to flee (within last 5 seconds)
func is_about_to_flee() -> bool:
	return not fleeing and lifetime_timer <= 5.0

# Function to extend lifetime (useful for power-ups or special events)
func extend_lifetime(additional_time: float):
	if not fleeing:
		lifetime_timer += additional_time
		print("Fish lifetime extended by %.1f seconds" % name, additional_time)

# Function to check if fish has escaped from fishing rod
func has_escaped_from_rod() -> bool:
	return has_escaped

# Function to get fish status information
func get_fish_status() -> Dictionary:
	return {
		"name": name,
		"biting": biting,
		"fleeing": fleeing,
		"escaped": has_escaped,
		"lifetime_remaining": get_remaining_lifetime(),
		"catch_chance": catch_chance,
		"value": value,
		"current_speed": get_current_speed(),
		"fade_progress": flee_timer / flee_duration if fleeing else 0.0
	}

# Function to get the current speed of the fish
func get_current_speed() -> float:
	var current_speed = speed * speed_scale
	if has_escaped:
		current_speed *= escaped_speed_multiplier
	return current_speed

# Function to set fade duration for fleeing fish
func set_fade_duration(duration: float):
	flee_duration = duration
	print("Fish %s fade duration set to %.1f seconds" % [name, duration])

# Function to check if fish should be caught (based on catch chance)
func should_be_caught() -> bool:
	var random_value = rng.randf()  # Random value between 0.0 and 1.0
	var caught = random_value <= catch_chance
	
	if caught:
		print("Fish %s caught! (chance: %.1f%%, roll: %.3f)" % [name, catch_chance * 100, random_value])
	else:
		print("Fish %s escaped! (chance: %.1f%%, roll: %.3f)" % [name, catch_chance * 100, random_value])
	
	return caught

# Function called when fish escapes from fishing rod
func escape_from_rod():
	print("Fish %s escaped the hook and is fleeing immediately!" % name)
	# Make sure the fish is not biting anymore
	biting = false
	target_rod = null
	rotation = 0
	has_escaped = true  # Mark this fish as having escaped
	
	# Make the fish flee immediately instead of waiting for lifetime
	flee()

# Function to force destroy the fish (used when caught)
func force_destroy():
	print("Force destroying fish: %s" % name)
	# Disconnect any signals to prevent memory leaks
	if hitbox and hitbox.area_entered.is_connected(_on_hitbox_area_entered):
		hitbox.area_entered.disconnect(_on_hitbox_area_entered)
	# Remove from groups
	remove_from_group("fish")
	# Queue for destruction
	queue_free()

func _draw():
	if draw_hitbox and hitbox:
		var pos := hitbox.position
		draw_circle(pos, 6, Color.RED)
	
	# Draw a warning indicator when fish is about to flee
	if is_about_to_flee() and not fleeing:
		var warning_color = Color.YELLOW
		if lifetime_timer <= 2.0:
			warning_color = Color.RED  # Red when very close to fleeing
		
		# Draw a small warning circle above the fish
		var warning_pos = Vector2(0, -20)
		draw_circle(warning_pos, 3, warning_color)
		
		# Draw lifetime bar
		var bar_width = 20.0
		var bar_height = 2.0
		var bar_pos = Vector2(-bar_width/2, -25)
		
		# Background bar
		draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color.DARK_GRAY)
		
		# Lifetime bar
		var lifetime_percentage = get_lifetime_percentage()
		var fill_width = bar_width * lifetime_percentage
		draw_rect(Rect2(bar_pos, Vector2(fill_width, bar_height)), warning_color)
	
	# Draw indicator for escaped fish
	if has_escaped and not fleeing:
		# Draw a red circle above the fish to show it has escaped
		var escape_pos = Vector2(0, -30)
		draw_circle(escape_pos, 4, Color.RED)
		# Draw an X inside the circle
		draw_line(escape_pos + Vector2(-2, -2), escape_pos + Vector2(2, 2), Color.WHITE, 1.0)
		draw_line(escape_pos + Vector2(2, -2), escape_pos + Vector2(-2, 2), Color.WHITE, 1.0)
		
		# Draw speed indicator (2x symbol) - simplified without font
		var speed_pos = Vector2(0, -40)
		draw_circle(speed_pos, 3, Color.YELLOW)
		# Draw a simple 2x indicator with lines instead of text
		draw_line(speed_pos + Vector2(-1, -1), speed_pos + Vector2(1, 1), Color.BLACK, 1.0)
		draw_line(speed_pos + Vector2(1, -1), speed_pos + Vector2(-1, 1), Color.BLACK, 1.0) 
