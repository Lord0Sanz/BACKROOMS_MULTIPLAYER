extends Node3D

@onready var ui: Control = $UI
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene
@export var debug_mode: bool = false  # Toggle for debug prints

# Fixed spawn positions
var spawn_positions = [
	Vector3(8.0, 0.0, 6.0),
	Vector3(13.0, 0.0, 12.0),
	Vector3(12.0, 0.0, -10.0),
	Vector3(-7.0, 0.0, -7.0),
	Vector3(-9.0, 0.0, -13.0),
	Vector3(-14.0, 0.0, 8.0)
]
var available_spawn_positions = []
var client_counter = 0  # Counter to track clients for unique IPs

func _ready():
	# Initialize available positions
	available_spawn_positions = spawn_positions.duplicate()
	available_spawn_positions.shuffle()
	
	# Configure multiplayer spawner
	multiplayer_spawner.spawn_function = _spawn_player

func _on_host_pressed() -> void:
	peer.create_server(1027)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# Reset client counter when hosting
	client_counter = 0
	
	# Host spawns themselves
	var spawn_data = {"player_id": 1, "spawn_pos": get_available_spawn_position(), "is_host": true, "client_index": 0}
	multiplayer_spawner.spawn(spawn_data)
	ui.hide()
	
	if debug_mode:
		print("SERVER STARTED - Waiting for clients...")

func _on_join_pressed() -> void:
	var ip_address = "127.0.0.1"
	peer.create_client(ip_address, 1027)
	multiplayer.multiplayer_peer = peer
	ui.hide()
	
	if debug_mode:
		print("CONNECTING TO SERVER at ", ip_address, "...")

func _on_peer_connected(id: int):
	if debug_mode:
		print("CLIENT CONNECTED - Player ID: ", id)
		
	if multiplayer.is_server():
		client_counter += 1
		var spawn_data = {"player_id": id, "spawn_pos": get_available_spawn_position(), "is_host": false, "client_index": client_counter}
		multiplayer_spawner.spawn(spawn_data)

func _on_peer_disconnected(id: int):
	if debug_mode:
		print("CLIENT DISCONNECTED - Player ID: ", id)
		
	if multiplayer.is_server():
		# Find and remove the player
		var player_node = get_node_or_null(str(id))
		if player_node:
			# Return spawn position
			var player_pos = player_node.global_position
			for spawn_pos in spawn_positions:
				if spawn_pos.distance_to(player_pos) < 0.1:
					available_spawn_positions.append(spawn_pos)
					break
			player_node.queue_free()

func _spawn_player(spawn_data: Dictionary) -> Node:
	var player = player_scene.instantiate()
	player.name = str(spawn_data["player_id"])
	
	# Set professional player info with unique IPs
	var player_name = "HOST" if spawn_data["is_host"] else "CLIENT"
	var player_ip = ""
	
	if spawn_data["is_host"]:
		player_ip = "127.0.0.0"  # Host gets .0
	else:
		# Clients get incrementing IPs: .1, .2, .3, etc.
		var ip_suffix = spawn_data["client_index"]
		player_ip = "127.0.0." + str(ip_suffix)
	
	player.set_player_info(player_name, player_ip, spawn_data["is_host"])
	
	# Store the spawn position in the player for later use
	player.set_meta("spawn_position", spawn_data["spawn_pos"])
	
	if debug_mode:
		print("SPAWNING: ", player_name, " with IP: ", player_ip, " at position: ", spawn_data["spawn_pos"])
		
	return player

func get_available_spawn_position():
	if available_spawn_positions.size() > 0:
		return available_spawn_positions.pop_front()
	else:
		var random_x = randf_range(-15, 15)
		var random_z = randf_range(-15, 15)
		return Vector3(random_x, 0, random_z)
