extends Node3D

@onready var camera = $"Camera3D"
@onready var selector = $"Selector"
@onready var UI = $UI
@onready var pointTargetModel = preload("res://assets/models/pointTarget/pointTarget.tscn")

var is_mouse_in_window = true

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	
func _ready():
	if not is_multiplayer_authority(): return
	camera.current = true
	UI.visible = true
	
	var target = pointTargetModel.instantiate()
	target.name = "pointTarget" + str(name)
	self.add_child(target)

func _input(event):
	if not is_multiplayer_authority(): return
	if not is_mouse_in_window: return
	
	var ray_origin = Vector3()
	var ray_target = Vector3()

	var mouse_position = get_viewport().get_mouse_position()
	
	ray_origin = camera.project_ray_origin(mouse_position)
	ray_target = ray_origin + camera.project_ray_normal(mouse_position) * 2000
	
	var space_state = get_world_3d().direct_space_state
	var intersection = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_origin, ray_target))
	
	if not intersection.is_empty():
		if event is InputEventMouseButton and event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					pass
				MOUSE_BUTTON_RIGHT:
					var pos = intersection.position
					updatePointTarget(pos)
					moveUnits(pos)

func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		is_mouse_in_window = true
	elif what == NOTIFICATION_WM_MOUSE_EXIT:
		is_mouse_in_window = false
				
func updatePointTarget(pos: Vector3):
	var pointTarget = get_node("pointTarget" + str(name))
	pointTarget.position = pos + Vector3(0,0.1,0)
	pointTarget.play()

func moveUnits(pos: Vector3):
	if not selector.selected: return
	for unit in selector.selected:
		unit.move_toward_pos.rpc(pos)
