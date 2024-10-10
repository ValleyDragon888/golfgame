extends Node3D

const num_players = 2
var turn = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# debug, remove later
	GlobalVariables.trackplayer_debug_enabled = false
	GlobalVariables.trackplayer_requested_scene_load = "res://Tracks/JSON/MainCampaign/01.json"
	
	for i in range(num_players):
		var new_player = Node3D.new()
		new_player.position.x = i*1000
		new_player.add_child(GlobalVariables.trackplayer.instantiate())
		new_player.name = "Player" + str(i)
		$Players.add_child(new_player)
	
	update_turn()

func update_turn():
	for i in range(num_players):
		if i == turn:
			var camera = get_node("/root/MultiplayerTrackPlayer/Players/Player" + str(i) + "/TrackPlayer/Player/CameraPivotV/CameraPivotH/SpringArm3D/Camera3D")
			camera.current = true
		else:
			var camera = get_node("/root/MultiplayerTrackPlayer/Players/Player" + str(i) + "/TrackPlayer/Player/CameraPivotV/CameraPivotH/SpringArm3D/Camera3D")
			camera.current = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_Q):
		print("chonk")
		turn = 1
		update_turn()
