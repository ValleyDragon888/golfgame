extends Node3D


@onready var block_instances: Array[EditorBlockInstance] = []
@onready var save_path = ""
@onready var load_confirmation_dialog = $Debug/LoadDialog
@onready var load_fileselector = $Debug/LoadFileSelectorDialog
@onready var player = $Player
@export var is_child = false
@export var is_disabled = false 
var multiplayer_master = ""

func _ready():
	if GlobalVariables.trackplayer_debug_enabled == false:
		load_file(GlobalVariables.trackplayer_requested_scene_load)
		$Debug.hide()
	if is_child:
		$Player/Ball.is_child = true
		$Player/Ball.local_multiplayer_enabled = true
		multiplayer_master = get_tree().root.get_child(1)

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
	var json_decoded = JSON.parse_string(contents)

	# Remove blocks in scene tree and script cache
	block_instances = []
	for child in $AddedBlocksRoot.get_children():
		$AddedBlocksRoot.remove_child(child)

	# Add blocks from file.
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

	player.get_child(0).position = GlobalVariables.start_position * 6
	player.get_child(0).position.y = GlobalVariables.start_position.y * 6 + 5

func _process(_delta):
	if GlobalVariables.finished:
		$FinishedScreen.show()
	else:
		$FinishedScreen.hide()

	if GlobalVariables.checkpoint_to_delete[1] == true:
		block_instances.remove_at(GlobalVariables.checkpoint_to_delete[0])
		$AddedBlocksRoot.remove_child($AddedBlocksRoot.get_child(GlobalVariables.checkpoint_to_delete[0]))
		GlobalVariables.checkpoint_to_delete[1] = false

func _on_continue_pressed():
	get_tree().change_scene_to_packed(GlobalVariables.homepage)
	GlobalVariables.finished = false

func _on_back_pressed():
	get_tree().change_scene_to_packed(GlobalVariables.homepage)

func _on_restart_pressed():
	get_tree().reload_current_scene()

func disable():
	is_disabled = true
	$Player/Ball.disable()
	
func enable():
	is_disabled = false
	$Player/Ball.enable()
