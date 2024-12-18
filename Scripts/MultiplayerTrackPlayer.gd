extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
@onready var block_instances: Array[EditorBlockInstance] = []
@onready var save_path = ""
@onready var load_confirmation_dialog = $Debug/LoadDialog
@onready var load_fileselector = $Debug/LoadFileSelectorDialog
@onready var players_connected = $StartScreen/PlayersConnected
var player

@rpc
func update_variables(SP, JSON_Contents):
	load_course(JSON_Contents)

@rpc
func start_game():
	$StartScreen.hide()
	$ScreenUI/Panel2.hide()

@rpc
func Update_LAN_player_names(New_LAN_player_names):
	GlobalVariables.LAN_player_names = New_LAN_player_names
	players_connected.clear()
	for item in len(GlobalVariables.LAN_player_names):
		players_connected.add_item(str(GlobalVariables.LAN_player_names[item]))

func _ready():
	$StartScreen/TextEdit.text = GlobalVariables.player_name
	if GlobalVariables.trackplayer_debug_enabled == false:
		load_file(GlobalVariables.trackplayer_requested_scene_load)
		$Debug.hide()

func block_instance_from_json(a: Dictionary, id: int) -> EditorBlockInstance:
	return EditorBlockInstance.new(
		id,
		Vector3(a["position"][0], a["position"][1], a["position"][2]),
		Vector3(a["rotation"][0], a["rotation"][1], a["rotation"][2]),
		a["type"]
	)

func _on_load_button_pressed():
	load_confirmation_dialog.popup()

func _on_load_dialog_confirmed():
	load_fileselector.popup()

func _on_load_file_selector_dialog_file_selected(path):
	load_file(path)
	
func load_file(path):
	# Read in and decode json
	save_path = path
	var file = FileAccess.open(path, FileAccess.READ)
	var contents = file.get_as_text()
	var file_name = path.split("/", true, 0)
	$StartScreen/TrackSeleceted.text = file_name[file_name.size()-1]
	
	load_course(contents)
	rpc("update_variables", GlobalVariables.start_position, contents)

func _process(_delta):
	if GlobalVariables.finished:
		$FinishedScreen.show()
	else:
		$FinishedScreen.hide()

	if GlobalVariables.checkpoint_to_delete[1] == true:
		block_instances.remove_at(GlobalVariables.checkpoint_to_delete[0])
		$AddedBlocksRoot.remove_child($AddedBlocksRoot.get_child(GlobalVariables.checkpoint_to_delete[0]))
		GlobalVariables.checkpoint_to_delete[1] = false

	if multiplayer.is_server():
		rpc("Update_LAN_player_names", GlobalVariables.LAN_player_names)
		players_connected.clear()
		for item in len(GlobalVariables.LAN_player_names):
			players_connected.add_item(str(GlobalVariables.LAN_player_names[item]))

func _on_continue_pressed():
	get_tree().change_scene_to_packed(GlobalVariables.homepage)
	GlobalVariables.finished = false

func _on_back_pressed():
	get_tree().change_scene_to_packed(GlobalVariables.homepage)

func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_host_pressed():
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	$StartScreen/HBoxContainer.hide()
	$StartScreen/HBoxContainer2.show()
	$StartScreen/Start.show()

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)
	print("id: ",id,"   name: ",player.name)

func _on_join_pressed():
	peer.create_client("localhost",135)
	multiplayer.multiplayer_peer = peer
	$StartScreen/HBoxContainer.hide()
	$StartScreen/Panel.hide()

func load_course(contents):
	var json_decoded = JSON.parse_string(contents)

	block_instances = []
	for child in $AddedBlocksRoot.get_children():
		$AddedBlocksRoot.remove_child(child)

	# Add blocks from file.
	if not json_decoded == null:
		for i in len(json_decoded["blocks"]):
			# The last arg of blkinstance from json is the id.
			block_instances.append(block_instance_from_json(json_decoded["blocks"][i], i))
			$AddedBlocksRoot.add_child(block_instances[-1].node())

		$AddedBlocksRoot.remove_child($AddedBlocksRoot.get_child(0))
		GlobalVariables.start_position.x = block_instances[0].get_json_dict().position[0]
		GlobalVariables.start_position.y = block_instances[0].get_json_dict().position[1]
		GlobalVariables.start_position.z = block_instances[0].get_json_dict().position[2]
		block_instances[0].type = "StartIndicator"
		$AddedBlocksRoot.add_child(block_instances[0].node())
		$AddedBlocksRoot.move_child($AddedBlocksRoot.get_children()[-1], 0)

		$AddedBlocksRoot.remove_child($AddedBlocksRoot.get_child(1))
		GlobalVariables.end_position.x = block_instances[1].get_json_dict().position[0]
		GlobalVariables.end_position.y = block_instances[1].get_json_dict().position[1]
		GlobalVariables.end_position.z = block_instances[1].get_json_dict().position[2]
		block_instances[1].type = "EndIndicator"
		$AddedBlocksRoot.add_child(block_instances[1].node())
		$AddedBlocksRoot.move_child($AddedBlocksRoot.get_children()[-1], 1)

		#Adds checkpoints to the variable.
		GlobalVariables.checkpoints.clear()
		for item in len(block_instances):
			if block_instances[item].get_json_dict().type == "CheckpointMarker":
				GlobalVariables.checkpoints.append(Vector4(block_instances[item].get_json_dict().position[0], block_instances[item].get_json_dict().position[1], block_instances[item].get_json_dict().position[2], item))
				print(GlobalVariables.checkpoints)
	else:
		$StartScreen/TrackSeleceted.text = "No track selected (An error occured)"

func _on_start_pressed():
	$StartScreen.hide()
	$ScreenUI/Panel2.hide()
	rpc("start_game")
	GlobalVariables.started = true


func _on_ok_pressed():
	$IntroductionScreen.hide()
	$StartScreen.show()


func _on_text_edit_text_changed():
	GlobalVariables.player_name = $StartScreen/TextEdit.text


func _on_campaign_button_pressed():
	$StartScreen.hide()
	$StartScreen/CampaignSelector.show_campaign_screen("Main Campaign")
	$StartScreen/CampaignSelector/Panel2.show()

func _on_campaign_back_pressed():
	$StartScreen/CampaignSelector/Panel2.hide()
	$StartScreen.show()
	$StartScreen/CampaignSelector.hide()
	$StartScreen/CampaignSelector/Back.hide()
	$StartScreen/CampaignSelector/Title.hide()
	$StartScreen/CampaignSelector/TracksList.hide()
