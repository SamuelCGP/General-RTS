extends CharacterBody3D

@onready var selection = $"Selection"
@onready var range_collider = $"Range"
@onready var model = $"Monday Cat"
@onready var desired_position = position

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var model_initial_rotation

var SPEED = 20
var actions = ["move", "attack"]
var standard_interaction = {"team": "attack", "enemy": "attack"}
var state = "idle"
var current_target

func _ready():
	add_to_group("selectables")
	model.visible = true
	model_initial_rotation = model.rotation

func _physics_process(delta):
	if not is_on_floor(): velocity.y -= gravity * delta
	
	if current_target: attack(current_target, false)
	
	movement()

func movement():
	if position.distance_to(desired_position) > 0.5:
		var normal_to_pos = get_normal_to_pos(desired_position)
		velocity.x = normal_to_pos.x * SPEED
		velocity.z = normal_to_pos.z * SPEED
		
		look_at_y(desired_position)
	elif desired_position != position: stop_movement()

	move_and_slide()

@rpc("any_peer","call_local")
func move_toward_pos(pos: Vector3, outside_call = true):
	if outside_call: current_target = null
	desired_position = Vector3(pos.x, position.y, pos.z)
	state = "moving"

func stop_movement(): 
	desired_position = position
	velocity.x = 0
	velocity.z = 0
	if state != "attacking": state = "idle"

@rpc("any_peer","call_remote")
func attack(target = current_target, outside_call = true):
	if outside_call and target:
		current_target = get_selectable_in_world(target) if typeof(target) == TYPE_STRING_NAME else target
		if not typeof(target) == TYPE_STRING_NAME: attack.rpc(current_target.name)
	
	if current_target == self: current_target = null
	if not current_target: return

	if current_target in range_collider.get_overlapping_bodies():
		# DO DAMAGE HERE
		state = "attacking"
		look_at_y(current_target.position)
		stop_movement()
		return
	move_toward_pos(current_target.position, false)

func get_selectable_in_world(node_name: StringName):
	var selectables = get_tree().get_nodes_in_group("selectables")
	for node in selectables:
		if node.name == node_name: return node
	return null

func get_normal_to_pos(pos: Vector3):
	return (pos - position).normalized()

func look_at_y(pos: Vector3):
	model.look_at(pos, Vector3.UP)
	model.rotation.z = model_initial_rotation.z
	model.rotation.x = model_initial_rotation.x

func select(i: bool = true): selection.visible = i
func deselect(): select(false)
