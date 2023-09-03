extends CharacterBody3D

var SPEED = 1 + (randi() % 20)

@onready var model = $"Monday Cat"
@onready var selection = $"Selection"
var desired_position = position

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	add_to_group("selectables")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if snapped(position.x, 0.1) != snapped(desired_position.x, 0.1) \
	and snapped(position.z, 0.1) != snapped(desired_position.z, 0.1):
		var normal_to_pos = get_normal_to_pos(desired_position)
		velocity.x = normal_to_pos.x * SPEED
		velocity.z = normal_to_pos.z * SPEED
		model.rotation.y = atan2(velocity.x, velocity.z)
		model.rotate(Vector3(0,1,0), PI)
	else:
		desired_position = position
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

func move_toward_pos(pos: Vector3):
	desired_position = Vector3(pos.x, position.y, pos.z)

func get_normal_to_pos(pos: Vector3):
	return (pos - position).normalized()

func select(i: bool = true):
	selection.visible = i
func deselect():
	select(false)
