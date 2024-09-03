extends Node3D

@onready var show_blocks_button = $CanvasLayer/ShowHideButton
@onready var blocks_ui_showing = false
@onready var blocks_ui_root = $CanvasLayer/ItemList
@onready var block_selected: String = "TrackStraight"
@onready var y_plane = $YPlane
@onready var block_instances: Array[EditorBlockInstance] = []
@onready var save_path = ""
@onready var save_as_dialog = $CanvasLayer/SaveAsDialog
@onready var load_confirmation_dialog = $CanvasLayer/LoadDialog
@onready var load_fileselector = $CanvasLayer/LoadFileSelectorDialog
@export var valid_blocks = [
		"TrackStraight",
		"TrackCornerSharp"
	]

# Called when the node enters the scene tree for the first time.
func _ready():
	for block in valid_blocks:
		blocks_ui_root.add_item(block)
	blocks_ui_root.select(0)
	
	block_instances.append(EditorBlockInstance.new(0, Vector3.ZERO, Vector3.ZERO, "TrackStraight"))
	$AddedBlocksRoot.add_child(block_instances[0].node())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			# Why. WHY IS GODOT Z = Y NOOOOOOOO
			y_plane.position.y += 1
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			# Sanity levels just dropped
			y_plane.position.y -= 1

func set_save_path():
	save_as_dialog.popup()

func save():
	var json_dict: Dictionary = {"blocks":[]}
	for block in block_instances:
		json_dict["blocks"].append(block.get_json_dict())
	var json_dict_str = JSON.stringify(json_dict, "\t")
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(json_dict_str)
	file.close()

func block_instance_from_json(a: Dictionary, id: int) -> EditorBlockInstance:
	return EditorBlockInstance.new(
		id,
		Vector3(a["position"][0], a["position"][1], a["position"][2]),
		Vector3(a["rotation"][0], a["rotation"][1], a["rotation"][2]),
		a["type"]
	)

func _on_show_hide_button_pressed():
	# lazy. this checks if text is "show blocks"
	if show_blocks_button.text[0] == "S":
		show_blocks_button.text = "Hide Blocks"
		blocks_ui_root.show()
	else:
		show_blocks_button.text = "Show Blocks"
		blocks_ui_root.hide()


func _on_item_list_item_selected(index):
	# Here, block_selected is the block in the menu
	block_selected = valid_blocks[index]
	print_debug(block_selected)

func _on_save_button_pressed():
	save()

func _on_save_path_button_pressed():
	set_save_path()


func _on_save_as_dialog_file_selected(path):
	save_path = path

func _on_load_button_pressed():
	load_confirmation_dialog.popup()

func _on_load_dialog_confirmed():
	load_fileselector.popup()

func _on_load_file_selector_dialog_file_selected(path):
	# Read in and decode json
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
