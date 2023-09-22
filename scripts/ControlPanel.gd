extends PanelContainer

@onready var selector = $"../../Selector"
@onready var area_2d = $Area2D
@onready var unit_container = $MarginContainer/HBoxContainer/UnitContainer
@onready var action_container = $MarginContainer/HBoxContainer/ActionContainer

var unit_button = preload("res://scenes/unit_button.tscn")
var action_button = preload("res://scenes/action_button.tscn")

var is_mouse_in = false

func _ready():
	selector.connect("new_selection", update_ui)
	area_2d.connect("mouse_entered", mouse_in)
	area_2d.connect("mouse_exited", mouse_out)

func update_ui(selection):
	for n in unit_container.get_children():
		unit_container.remove_child(n)
		n.queue_free()
	for n in action_container.get_children():
		action_container.remove_child(n)
		n.queue_free()
	
	if not selection: return
	
	var first_selected
	
	for n in selection:
		if not first_selected: first_selected = n
		var button = unit_button.instantiate()
		button.linked_unit = n
		unit_container.add_child(button)
	
	for action in first_selected.actions:
		var button = action_button.instantiate()
		button.action = action
		action_container.add_child(button)

func mouse_in(): is_mouse_in = true
func mouse_out(): is_mouse_in = false
