extends Node3D

const num_players = 2
var turn = 0
var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

func _on_host_pressed():
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)

func _on_join_pressed():
	peer.create_client("localhost",135)
	multiplayer.multiplayer_peer = peer
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# debug, remove later
	GlobalVariables.trackplayer_debug_enabled = false
	GlobalVariables.trackplayer_requested_scene_load = "res://Tracks/JSON/MainCampaign/01.json"

	update_turn()

func update_turn():
	for i in range(num_players):
		if i == turn:
			print(i)
			var camera = get_node("/root/MultiplayerTrackPlayer/Players/Player" + str(i) + "/TrackPlayer/Player/CameraPivotV/CameraPivotH/SpringArm3D/Camera3D")
			camera.current = true
			get_node("/root/MultiplayerTrackPlayer/Players/Player" + str(i) + "/TrackPlayer").enable()
		else:
			print(i)
			var camera = get_node("/root/MultiplayerTrackPlayer/Players/Player" + str(i) + "/TrackPlayer/Player/CameraPivotV/CameraPivotH/SpringArm3D/Camera3D")
			#camera.current = false
			get_node("/root/MultiplayerTrackPlayer/Players/Player" + str(i) + "/TrackPlayer").disable()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(turn)
	if Input.is_key_pressed(KEY_Q):
		print("chonk")
		turn = 1
		update_turn()
   
func next_turn():
	turn += 1
	if turn >= num_players:
		turn = 0
	update_turn()
