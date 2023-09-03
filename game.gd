extends Node3D

@onready var camera = get_node("Camera3D")
@onready var selector = get_node("Selector")
@onready var pointTargetModel = preload("res://assets/models/pointTarget/pointTarget.tscn")

func _ready():
	var target = pointTargetModel.instantiate()
	target.name = "pointTarget"
	self.add_child(target)

func _input(event):
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
					
func updatePointTarget(pos: Vector3):
	var pointTarget = get_node("pointTarget")
	pointTarget.position = pos + Vector3(0,0.1,0)
	pointTarget.play()

func moveUnits(pos: Vector3):
	for unit in selector.selected:
		unit.move_toward_pos(pos)
