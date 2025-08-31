extends Control
class_name MoneyDisplay

@export var moneyLabel : Label
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	moneyLabel.text = str(Globals.money)
