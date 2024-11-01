extends Node3D

const num_players = 2
var turn = 0
var finished_players = []
var finished_names = []
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# debug, remove later
	GlobalVariables.trackplayer_debug_enabled = false
	GlobalVariables.trackplayer_requested_scene_load = "res://Tracks/JSON/MainCampaign/01.json"
	
	for i in range(num_players):
		var new_player = Node3D.new()
		new_player.position.x = i*1000
		new_player.add_child(GlobalVariables.trackplayer.instantiate())
		new_player.get_children()[0].is_child = true
		print(GlobalVariables.local_multiplayer_player_details[i]["name"])
		new_player.get_children()[0].get_node("Player").get_children()[0].player_name = GlobalVariables.local_multiplayer_player_details[i]["name"]
		new_player.name = "Player" + str(i)
		$Players.add_child(new_player)
	
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
	
	#$CanvasLayer/PlayerIndicator.text = "Player " + str(turn+1)
	$CanvasLayer/PlayerIndicator.text = GlobalVariables.local_multiplayer_player_details[turn]["name"]

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
	if GlobalVariables.local_multiplayer_player_details[turn]["name"] in finished_names:
		next_turn()
		print("nextt")
	update_turn()

func finished(player_name, shots):
	print(player_name)
	finished_players.append({
		"name":GlobalVariables.local_multiplayer_player_details[turn]["name"],
		"shots":shots}
	)
	finished_names.append(player_name)
	if not len(finished_players) == len(GlobalVariables.local_multiplayer_player_details):
		next_turn()
	else:
		print("ALL FINISED")
		print(finished_players)
	
