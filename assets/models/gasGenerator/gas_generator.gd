extends Node3D

@onready var ap: AnimationPlayer  = get_node("AnimationPlayer")

func _ready():
	idle()

func build():
	ap.play("building")

func idle():
	ap.get_animation("idle").loop_mode = Animation.LOOP_LINEAR
	ap.play("idle")
