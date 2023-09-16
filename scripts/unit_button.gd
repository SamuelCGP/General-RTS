extends Button

@onready var selector = get_node("../../../../../../Selector")
var linked_unit

func _ready():
	connect("pressed", select_unit)

func select_unit():
	selector.selected = [linked_unit]
