extends Node3D

@onready var camera = $"Camera3D"
@onready var selector = $"Selector"
@onready var UI = $UI
@onready var control_panel = $UI/ControlPanel
@onready var pointTargetModel = preload("res://assets/models/pointTarget/pointTarget.tscn")

signal action_changed

var is_mouse_in_window = true
var action = "select" :
	set(value):
		action = value
		emit_signal("action_changed", value)

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	
func _ready():
	UI.visible = false
	if not is_multiplayer_authority(): return
	camera.current = true
	UI.visible = true
	
	var target = pointTargetModel.instantiate()
	target.name = "pointTarget" + str(name)
	self.add_child(target)

func _input(event):
	if not is_multiplayer_authority(): return
	if not is_mouse_in_window: return
	if control_panel.is_mouse_in == true: return
	
	if event is InputEventMouseButton and event.pressed:
		_mouseInputHandle(event)

func _mouseInputHandle(event):
	var mouse_position = get_viewport().get_mouse_position()
	
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_target = ray_origin + camera.project_ray_normal(mouse_position) * 2000
	
	var space_state = get_world_3d().direct_space_state
	var intersection = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_origin, ray_target))
	
	if not intersection.is_empty():
		var pos = intersection.position
		var collider = intersection.collider
		match(event.button_index):
			MOUSE_BUTTON_RIGHT:
				if call_standard_interacton(collider): pass
				else: move_units(pos)
			MOUSE_BUTTON_LEFT:
				match(action):
					"select": pass
					"attack": order_attack(collider)
					"move": move_units(pos)
		action = "select"

func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		is_mouse_in_window = true
	elif what == NOTIFICATION_WM_MOUSE_EXIT:
		is_mouse_in_window = false

func update_point_target(pos: Vector3):
	var pointTarget = get_node("pointTarget" + str(name))
	pointTarget.position = pos + Vector3(0,0.1,0)
	pointTarget.play()

func move_units(pos: Vector3):
	if not selector.selected: return
	action = "move"
	update_point_target(pos)
	for unit in selector.selected:
		unit.move_toward_pos.rpc(pos)

func order_attack(target):
	if not selector.selected: return
	if not target.is_in_group("selectables"): return
	action = "attack"
	for unit in selector.selected:
		unit.attack(target)

func call_standard_interacton(target):
	if not selector.selected: return
	if not target.is_in_group("selectables"): return
	action = target.standard_interaction.team
	for unit in selector.selected:
		unit.call(target.standard_interaction.team, target)
	return true
