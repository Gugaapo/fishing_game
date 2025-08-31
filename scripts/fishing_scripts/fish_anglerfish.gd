extends FishBase

func _ready():
	# Override default values for baiacu
	speed = 40.0  # Baiacu is slower than basic fish
	amplitude = 450.0  # Smaller movement range
	random_speed_range = Vector2(0.85, 1.15)  # More variation for baiacu
	value = 50  # Baiacu fish are worth 25 points (rarer, more valuable)
	lifetime = 35.0  # Baiacu fish stay on screen longer (35 seconds)
	catch_chance = 0.3  # Baiacu fish have 50% catch chance (harder to catch)
	flee_duration = 6.0  # Baiacu fish fade out in 4 seconds (slower, more dramatic)
	
	super._ready()
