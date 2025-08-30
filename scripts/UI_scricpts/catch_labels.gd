extends Control
class_name CatchUIControl

signal finished(which: StringName)  # Optional: emit when the fade finishes ("miss" / "hit")

@export var fade_delay := 1.0    # seconds to wait before starting fade
@export var fade_time := 0.6     # seconds the fade takes
@export var float_up_px := 24.0  # set to 0 to disable upward drift

@onready var miss_label: Label = $MissLabel
@onready var hit_label: Label = $HitLabel

var _current: Label
var _tween: Tween

func _ready() -> void:
	_reset_labels()

func show_miss() -> void:
	_show_label(miss_label, &"miss")

func show_catch() -> void:
	_show_label(hit_label, &"hit")

func _reset_labels() -> void:
	for l in [miss_label, hit_label]:
		if l:
			l.visible = false
			l.modulate.a = 1.0

func _show_label(label: Label, which: StringName) -> void:
	# stop any existing animation
	if _tween:
		_tween.kill()
		_tween = null

	# reset both, then show the chosen one
	_reset_labels()
	_current = label
	_current.visible = true

	# capture start/end position (for float up)
	var start_pos := _current.position
	var end_pos := start_pos + Vector2(0, -float_up_px)

	# build tween: wait, then (optionally) move up + fade out, then hide + reset
	_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_interval(fade_delay)

	if float_up_px != 0.0:
		_tween.parallel().tween_property(_current, "position", end_pos, fade_time)

	_tween.parallel().tween_property(_current, "modulate:a", 0.0, fade_time)

	# On finish: hide, reset alpha & position, emit a signal. No queue_free.
	_tween.tween_callback(func ():
		_current.visible = false
		_current.modulate.a = 1.0
		_current.position = start_pos
		emit_signal("finished", which)
	)
