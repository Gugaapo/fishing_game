extends FishBase

func _ready():
	# Override default values for Espadim
	speed = 180.0  # Espadim is slower than basic fish
	amplitude = 450.0  # Smaller movement range
	random_speed_range = Vector2(0.85, 1.15)  # More variation for baiacu
	value = 75  # Espadim fish are worth 25 points (rarer, more valuable)
	lifetime = 35.0  # Espadim fish stay on screen longer (35 seconds)
	catch_chance = 0.3  # Espadim fish have 50% catch chance (harder to catch)
	flee_duration = 2.0  # Espadim fish fade out in 4 seconds (slower, more dramatic)
	
	
	super._ready()
