extends ColorRect

var mouse_down = false
var mouse_start_pos: Vector2
var mouse_end_pos: Vector2

@onready var camera: Camera3D = $"../Camera3D"

var selected = []

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if !mouse_down: 
				mouse_down = true
				mouse_start_pos = event.global_position
			$".".global_position = mouse_start_pos
		elif not event.is_pressed():
			if mouse_down:
				mouse_down = false
				mouse_end_pos = event.global_position
				if mouse_end_pos.distance_squared_to(mouse_start_pos) < 16:
					selected = get_selectable_under_mouse()
				else:
					selected = get_selectables_in_box()
				size = Vector2.ZERO
	if event is InputEventMouseMotion:
		if mouse_down:
			_drawBox()

func _drawBox():
	var gmp = get_global_mouse_position()
	var size_x = gmp.x - mouse_start_pos.x
	var size_y = gmp.y - mouse_start_pos.y
	scale.x = sign(size_x)
	scale.y = sign(size_y)
	size = Vector2(abs(size_x), abs(size_y))

func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = camera.project_ray_origin(m_pos)
	var ray_end = ray_start + camera.project_ray_normal(m_pos) * 1000
	var space_state = camera.get_world_3d().direct_space_state
	return space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_start, ray_end, collision_mask, []))
	
func get_selectable_under_mouse():
	var selectable_under_mouse = raycast_from_mouse(mouse_start_pos,1)
	if selected:
		for selectable in selected:
			selectable.deselect()
	if selectable_under_mouse and selectable_under_mouse.collider.is_in_group("selectables"):
		selectable_under_mouse.collider.select()
		return [selectable_under_mouse.collider]

func get_selectables_in_box():
	var top_left: Vector2 = mouse_start_pos
	var bot_right: Vector2 = mouse_end_pos
	
	if top_left.x > bot_right.x:
		var tmp = top_left.x
		top_left.x = bot_right.x
		bot_right.x = tmp
	if top_left.y > bot_right.y:
		var tmp = top_left.y
		top_left.y = bot_right.y
		bot_right.y = tmp
	
	var box = Rect2(top_left, bot_right - top_left)
	var box_selected = []
	for selectable in get_tree().get_nodes_in_group("selectables"):
		if box.has_point(camera.unproject_position(selectable.global_transform.origin)): #TODO condição para times depois
			box_selected.append(selectable)
			selectable.select()
		else:
			selectable.deselect()
	return box_selected
