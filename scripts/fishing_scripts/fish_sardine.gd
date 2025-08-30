extends FishBase

func _ready():
	# Override default values for sardine
	speed = 120.0
	amplitude = 200.0
	random_speed_range = Vector2(0.95, 1.10)
	value = 15  # Sardines are worth 15 points
	lifetime = 25.0  # Sardines stay on screen for 25 seconds
	catch_chance = 0.8  # Sardines have 80% catch chance (easier to catch)
	flee_duration = 2.5  # Sardines fade out in 2.5 seconds (faster)
	
	super._ready()
