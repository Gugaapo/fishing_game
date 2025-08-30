extends CharacterBody2D

const SPEED = 130.0

@onready var sprite = $Sprite2D # or $AnimatedSprite2D, adjust the path to your sprite node
@onready var fishing_rod = $FishingRod
@onready var rod_tip = $rodTip
@onready var bait_spawn = $baitSpawnPosition

var can_move := true
var facing_right := true

func _physics_process(delta):
	if Input.is_action_pressed("fish"):
		can_move = false
	# Get the input direction and handle the movement/deceleration.
	if can_move:
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
			# Flip sprite depending on direction
			if direction > 0 and not facing_right:
				flip_boat_right()
			elif direction < 0 and facing_right:
				flip_boat_left()
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = 0
	move_and_slide()

func flip_boat_right():
	facing_right = true
	sprite.flip_h = false
	# Adjust fishing rod tip position for right-facing
	rod_tip.position.x = 34
	bait_spawn.position.x = 34

func flip_boat_left():
	facing_right = false
	sprite.flip_h = true
	# Adjust fishing rod tip position for left-facing
	rod_tip.position.x = -32
	bait_spawn.position.x = -32
