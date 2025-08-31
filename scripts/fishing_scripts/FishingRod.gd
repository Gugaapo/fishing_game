extends Node2D

@export var radius: float = 20.0
@export var speed: float = 100.0
@export var bottom_y: float = 420.0
@export var spawn_offset_y: float = 32.0
@export var player_path: NodePath
@export var spawn_local_position_path: NodePath
@export var rod_tip_path: NodePath
@export var rod_tip_local_offset := Vector2(0, 0)
@export var line_color: Color = Color.WHITE
@export var line_width: float = 2.0

@export var catch_ui_control_path: NodePath
@export var return_scene_path: String = "res://scenes/map.tscn"  # scene to go back to

signal fish_caught(fish_value: int, fish_name: String)

var going_down := false
var returning_up := false
var spawn_position: Vector2
var player: Node2D

@onready var hitbox: Area2D = $Hitbox
@onready var rod_tip_node: Node2D = get_node_or_null(rod_tip_path) as Node2D if rod_tip_path != NodePath() else null
@onready var spawn_local_position_node: Node2D = get_node_or_null(spawn_local_position_path)
@onready var catch_ui_control: CatchUIControl = get_node_or_null(catch_ui_control_path)
@onready var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()

var _teleport_scheduled := false

func _ready():
	add_to_group("fishing_rod")
	hide()
	add_child(audio_player)

	if player_path != NodePath():
		player = get_node_or_null(player_path) as Node2D
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Node2D

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
	# no more “process later” points logic here — money updates instantly on catch

	queue_redraw()

func _draw():
	if not visible:
		return
	draw_circle(Vector2.ZERO, radius, Color.RED)
	var start_local := _get_rod_tip_local()
	if start_local != null:
		draw_line(start_local, Vector2.ZERO, line_color, line_width, true)

func _get_rod_tip_local() -> Vector2:
	if rod_tip_node:
		var tip_global := rod_tip_node.to_global(rod_tip_local_offset)
		return to_local(tip_global)
	return to_local(spawn_position)

# Called by a Fish when it collides with the ball
func on_hit_fish(fish: Node):
	if not visible:
		return

	if fish.has_method("should_be_caught") and fish.should_be_caught():
		if catch_ui_control:
			catch_ui_control.show_catch()

		# start reeling up if not already
		going_down = false
		returning_up = true

		# get fish value immediately
		var fish_value := 0
		if fish.has_method("on_caught"):
			fish_value = fish.on_caught()
		elif fish.has_method("get_value"):
			fish_value = fish.get_value()

		# 1) UPDATE MONEY INSTANTLY
		Globals.money += fish_value

		# 2) EMIT SIGNAL PER FISH (matches signal signature)
		fish_caught.emit(fish_value, fish.name)

		# 3) MAKE THE FISH DISAPPEAR NOW
		if fish.has_method("force_destroy"):
			fish.force_destroy()
		else:
			if fish.has_method("release"):
				fish.release()
			fish.queue_free()

		print("Caught %s! +%d money. Balance: %d" % [fish.name, fish_value, Globals.money])

		# 4) SCHEDULE RETURN AFTER 1s (money already updated)
		if not _teleport_scheduled:
			_schedule_return_after_delay()
	else:
		if catch_ui_control:
			catch_ui_control.show_miss()
		if fish.has_method("escape_from_rod"):
			fish.escape_from_rod()
		elif fish.has_method("flee"):
			fish.flee()
		print("Fish %s escaped the hook!" % fish.name)

# --- Return to scene after 1 second (but money already updated) ---
func _schedule_return_after_delay() -> void:
	_teleport_scheduled = true
	call_deferred("_do_return_after_delay")

func _do_return_after_delay() -> void:
	await get_tree().create_timer(1.0).timeout
	if return_scene_path == "":
		push_error("return_scene_path is empty.")
		_teleport_scheduled = false
		return
	if not ResourceLoader.exists(return_scene_path):
		push_error("Return scene does not exist: %s" % return_scene_path)
		_teleport_scheduled = false
		return
	print("Returning to:", return_scene_path)
	get_tree().change_scene_to_file(return_scene_path)

# --- Optional helpers (still work, now reflect Globals.money) ---
func get_total_points() -> int:
	return Globals.money

func reset_points():
	Globals.money = 0
	print("Money reset to 0")

func add_bonus_points(bonus: int):
	Globals.money += bonus
	print("Bonus! +%d. Balance: %d" % [bonus, Globals.money])
