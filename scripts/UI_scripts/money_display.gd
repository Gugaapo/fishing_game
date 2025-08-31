extends Control
class_name MoneyDisplay

@export var moneyLabel: Label
var _time_accum := 0.0   # keeps track of elapsed time

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# always update the label
	if moneyLabel:
		moneyLabel.text = str(Globals.money)

	# accumulate delta until 5 seconds pass
	_time_accum += delta
	if _time_accum >= 5.0:
		_time_accum = 0.0
		print("Level:", Globals.current_level)
		print("Event:", Globals.current_event)
