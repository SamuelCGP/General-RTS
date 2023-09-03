extends Node3D

@onready var ap: AnimationPlayer  = get_node("AnimationPlayer")
@onready var ap_opactity: AnimationPlayer = get_node("AnimationPlayerOpacity")

func _ready():
	play()

func play():
	ap.stop()
	ap_opactity.stop()
	ap.play("action")
	ap_opactity.play("opacity")
