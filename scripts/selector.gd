class_name Selector
extends ColorRect

signal new_selection

var mouse_down = false
var mouse_start_pos: Vector2
var mouse_end_pos: Vector2

@onready var camera: Camera3D = $"../Camera3D"
@onready var control_panel = $"../UI/ControlPanel"

var selected = [] :
	set(value):
		if selected:
			for selectable in selected:
				selectable.deselect()

		emit_signal("new_selection", value)
		selected = value
		
		if not value: return
		for selectable in value:
			selectable.select()

func _ready():
	# set authority to the owner's name
	set_multiplayer_authority(str(get_parent().name).to_int())

func _input(event):
	if not is_multiplayer_authority(): return
	if control_panel.is_mouse_in == true: return
	
	if event is InputEventMouseMotion and mouse_down: _drawBox()
	
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if not mouse_down: 
				mouse_down = true
				mouse_start_pos = event.global_position
			$".".global_position = mouse_start_pos
		elif not event.is_pressed() and mouse_down:
			mouse_down = false
			size = Vector2.ZERO
			mouse_end_pos = event.global_position
			
			var selection_area = abs(mouse_end_pos.x - mouse_start_pos.x)*abs(mouse_end_pos.y - mouse_start_pos.y)
			var threshold = selection_area < 600
			var new_selected = get_selectable_under_mouse() if threshold else get_selectables_in_box()
				
			if Input.is_action_pressed("shift"):
				if selected and new_selected:
					var tmp = selected
					
					for s in new_selected:
						if selected.has(s):
							new_selected.erase(s)
					
					tmp.append_array(new_selected)
					selected = tmp # tmp foi criado só para ter essa atribuição, dando trigger no set()
					return
			
			selected = new_selected

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
	var selectable_under_mouse = raycast_from_mouse(mouse_end_pos,1)
	if selectable_under_mouse and selectable_under_mouse.collider.is_in_group("selectables"):
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
	return box_selected
