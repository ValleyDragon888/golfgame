extends Node3D


@onready var blocks_ui_showing = false
@onready var block_instances: Array[EditorBlockInstance] = []
@onready var load_confirmation_dialog = $CanvasLayer/LoadDialog
@onready var load_fileselector = $CanvasLayer/LoadFileSelectorDialog
@onready var player = $Player

func block_instance_from_json(a: Dictionary, id: int) -> EditorBlockInstance:
	return EditorBlockInstance.new(
		id,
		Vector3(a["position"][0], a["position"][1], a["position"][2]),
		Vector3(a["rotation"][0], a["rotation"][1], a["rotation"][2]),
		a["type"]
	)

func _ready():
	var file = FileAccess.open(GlobalVariables.current_track, FileAccess.READ)
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
	
	$AddedBlocksRoot.remove_child($AddedBlocksRoot.get_child(0))	
	GlobalVariables.end_position.x = block_instances[1].get_json_dict().position[0]
	GlobalVariables.end_position.y = block_instances[1].get_json_dict().position[1]
	GlobalVariables.end_position.z = block_instances[1].get_json_dict().position[2]
	
	player.get_child(0).position = GlobalVariables.start_position * 6
	player.get_child(0).position.y = GlobalVariables.start_position.y * 6 + 10
	
func _on_editor_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Editor.tscn")
