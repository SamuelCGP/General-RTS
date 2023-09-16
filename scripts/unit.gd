extends CharacterBody3D

@onready var selection = $"Selection"
@onready var desired_position = position
@onready var model = $"Monday Cat"

var SPEED = 20
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var model_initial_rotation

func _ready():
	add_to_group("selectables")
	model.visible = true
	model_initial_rotation = model.rotation.y

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if position.distance_to(desired_position) > 0.5:
		var normal_to_pos = get_normal_to_pos(desired_position)
		velocity.x = normal_to_pos.x * SPEED
		velocity.z = normal_to_pos.z * SPEED
		
		model.rotation.y = model_initial_rotation + atan2(velocity.x, velocity.z) if velocity.z != 0 else model_initial_rotation
		model.rotate(Vector3.UP, PI)
	else:
		if desired_position != position:
			desired_position = position
			velocity.x = 0
			velocity.z = 0
			
	move_and_slide()

@rpc("any_peer","call_local")
func move_toward_pos(pos: Vector3):
	desired_position = Vector3(pos.x, position.y, pos.z)

func get_normal_to_pos(pos: Vector3):
	return (pos - position).normalized()

func select(i: bool = true):
	selection.visible = i
func deselect():
	select(false)
