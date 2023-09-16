extends Camera3D

var min_fov = fov
var max_fov = 25
var step = 1.05

var is_mouse_in_window = true

func _ready():
	# set authority to the owner's name
	set_multiplayer_authority(str(get_parent().name).to_int())

func _input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			match event.button_index:
				# zoom in
				MOUSE_BUTTON_WHEEL_UP:
					zoom_at_point(1/step, event.position)
				# zoom out
				MOUSE_BUTTON_WHEEL_DOWN:
					zoom_at_point(step, event.position)
					
func _process(_delta):
	if not is_multiplayer_authority(): return
	
	if not is_mouse_in_window: return
	border_move_camera(get_viewport().get_mouse_position())

func _get_mouse_factor(mouse_pos: Vector2):
	var v0 = get_viewport().size
	
	var factor = Vector2(mouse_pos.x - (v0.x/2), mouse_pos.y - (v0.y/2))	
	factor = Vector2(remap(factor.x, -(v0.x/2), (v0.x/2), -1, 1), remap(factor.y, -(v0.y/2), (v0.y/2), -1, 1))
	
	return factor

func zoom_at_point(zoom_change, point):
	if fov*zoom_change < min_fov:
		fov = min_fov
	elif fov*zoom_change > max_fov:
		fov = max_fov
	else:
		var c0 = global_position
		var factor = _get_mouse_factor(point)
		var c1 = Vector3(c0.x + step * factor.x, c0.y, c0.z + step * factor.y)
		global_position = c1
		fov *= zoom_change

func border_move_camera(mouse_pos: Vector2):
	var c0 = global_position
	var factor = _get_mouse_factor(mouse_pos)
	var c1 = c0
	if abs(factor.x) > 0.95 or abs(factor.y) > 0.95:
		c1.x += step * (-factor.y + factor.x)/2
		c1.z += step * (factor.y + factor.x)/2
	global_position = c1

func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		is_mouse_in_window = true
	elif what == NOTIFICATION_WM_MOUSE_EXIT:
		is_mouse_in_window = false
