extends Node3D

@onready var main_menu = $UI/MainMenu
@onready var address_entry = $UI/MainMenu/MarginContainer/VBoxContainer/Address

const Player = preload("res://scenes/player.tscn")
const Unit = preload("res://scenes/unit.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _on_host_button_pressed():
	main_menu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	add_unit(Vector3(-5,0,-5))
	add_unit(Vector3(5,0,5))

func _on_join_button_pressed():
	main_menu.hide()
	
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.server_disconnected.connect(handle_forced_disconnect)

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)

func remove_player(peer_id):
	get_node(str(peer_id)).queue_free()

func handle_forced_disconnect():
	main_menu.show()

func add_unit(pos = Vector3(0,0,0)):
	var unit = Unit.instantiate()
	unit.translate(pos)
	add_child(unit,true)
