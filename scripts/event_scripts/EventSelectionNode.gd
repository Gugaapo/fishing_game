# EventPanel.gd (Godot 4)
extends Control
class_name EventPanel

@export var title_path: NodePath
@export var description_path: NodePath
@export var tip_path: NodePath
@export var image_path: NodePath

var _title: Label
var _desc: Label          
var _tip: Label
var _image: TextureRect

func _ready():
	_title = get_node_or_null(title_path) as Label
	_desc  = get_node_or_null(description_path) as Label
	_tip   = get_node_or_null(tip_path) as Label
	_image = get_node_or_null(image_path) as TextureRect

func show_event(event_name: String) -> bool:
	var ev: EventData = EventDB.get_event(event_name)
	print(ev)
	print (event_name)
	if ev == null:
		push_warning("Event not found: %s" % event_name)
		return false

	if _title: _title.text = ev.name

	if _desc:
		if _desc is Label:
			(_desc as Label).text = ev.description

	if _tip: _tip.text = ev.tip
	if _image: _image.texture = ev.image

	return true
