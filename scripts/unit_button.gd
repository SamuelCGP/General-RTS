extends Button

@onready var selector = get_node("../../../../../../Selector")
var linked_unit

func _ready():
	connect("pressed", select_unit)

func select_unit():
	if Input.is_action_pressed("alt"):
		var tmp = selector.selected.duplicate(true)
		tmp.erase(linked_unit)
		selector.selected = tmp
		return

	selector.selected = [linked_unit]
