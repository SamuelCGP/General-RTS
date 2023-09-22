extends Button

@onready var player = get_node("../../../../../..")
@onready var selector = get_node("../../../../../../Selector")
@onready var label = get_node("Label")

var action

func _ready():
	connect("pressed", select_action)
	player.connect("action_changed", change_focus)
	var key = InputMap.action_get_events(action)[0].as_text().left(1)
	label.text = key

func _input(event): if event.is_action_pressed(action): select_action()

func select_action(): player.action = action

func change_focus(new_action): if new_action == action: grab_focus()
