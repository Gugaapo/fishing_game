extends Node2D

@export var search_roots: Array[Node]
@export var beach_path: String = "res://scenes/levels/beach.tscn"
@export var ice_path: String = "res://scenes/levels/ice.tscn"
@export var volcano_path: String = "res://scenes/levels/volcano.tscn"
@export var coral_path: String = "res://scenes/levels/coral.tscn"
@export var abyss_path: String = "res://scenes/levels/abyss.tscn"

# --- Fade-in settings ---
@export var fade_in_color: Color = Color.BLACK
@export var fade_in_duration: float = 0.6
var _fade_layer: CanvasLayer
var _fade_rect: ColorRect

var eventNames: Array[String] = [
	"The Downwind",
	"The Payment",
	"The Shoal",
	"The Storm",
	"The Strong Tide",
	"The Treasure",
	"???"
]

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

	# Create and run fade-in
	_create_fader()
	_fade_in()

	var pool: Array[String] = eventNames.duplicate()
	pool.shuffle()

	var count: int = min(search_roots.size(), pool.size())
	for i in range(count):
		var root: Node = search_roots[i] if search_roots[i] else self
		var event_name: String = pool[i]
		_assign_event_to_root(root, event_name)

	if search_roots.size() > pool.size():
		push_warning("More roots than available events; extra roots were not assigned.")

func _assign_event_to_root(root: Node, event_name: String) -> void:
	var panel: EventPanel = _find_event_panel(root)
	if panel:
		var ok := panel.show_event(event_name)
		if not ok:
			push_warning("Panel under %s could not show event '%s'." % [root.name, event_name])
	else:
		push_warning("EventPanel not found under %s" % root.name)

	var button: BaseButton = root.find_child("SailButton", true, false) as BaseButton
	if button:
		if not button.pressed.is_connected(Callable(self, "_on_sail_button_pressed")):
			button.pressed.connect(func():
				Globals.current_event = event_name
				_on_sail_button_pressed()
			)
	else:
		push_warning("SailButton not found under %s" % root.name)

func _find_event_panel(n: Node) -> EventPanel:
	var p: EventPanel = n as EventPanel
	if p:
		return p
	for child in n.get_children():
		var found := _find_event_panel(child)
		if found:
			return found
	return null

func _on_sail_button_pressed() -> void:
	# optional tiny delay to let SFX start
	await get_tree().process_frame
	await get_tree().create_timer(0.12).timeout

	var lvl := String(Globals.current_level).strip_edges().to_lower()
	var lvl_path: String
	match lvl:
		"beach":   lvl_path = beach_path
		"ice":     lvl_path = ice_path
		"volcano": lvl_path = volcano_path
		"coral":   lvl_path = coral_path
		"abyss":   lvl_path = abyss_path
		_:         lvl_path = beach_path
	get_tree().change_scene_to_file(lvl_path)

# --- Fade-in helpers ---
func _create_fader() -> void:
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100
	add_child(_fade_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.z_index = 1000
	_fade_rect.color = Color(fade_in_color.r, fade_in_color.g, fade_in_color.b, 1.0) # start opaque
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP   # block clicks during fade

	# Fill viewport
	_fade_rect.anchor_left = 0.0
	_fade_rect.anchor_top = 0.0
	_fade_rect.anchor_right = 1.0
	_fade_rect.anchor_bottom = 1.0
	_fade_rect.offset_left = 0
	_fade_rect.offset_top = 0
	_fade_rect.offset_right = 0
	_fade_rect.offset_bottom = 0

	_fade_layer.add_child(_fade_rect)

func _fade_in() -> void:
	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(
		_fade_rect,
		"color",
		Color(fade_in_color.r, fade_in_color.g, fade_in_color.b, 0.0),
		fade_in_duration
	)
	t.tween_callback(func():
		_fade_rect.visible = false
		_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE # no longer intercept input
	)
