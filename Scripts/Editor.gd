extends Node3D

@onready var show_blocks_button = $CanvasLayer/ShowHideButton
@onready var blocks_ui_showing = false
@onready var blocks_ui_root = $CanvasLayer/Tree
@onready var y_plane = $YPlane
@onready var block_instances: Array[EditorBlockInstance] = []
@onready var save_path = ""
@onready var save_as_dialog = $CanvasLayer/SaveAsDialog
@onready var load_confirmation_dialog = $CanvasLayer/LoadDialog
@onready var load_fileselector = $CanvasLayer/LoadFileSelectorDialog
@onready var categories = ["Standard Blocks", "Thin Blocks", "Transitions"]


# Called when the node enters the scene tree for the first time.
func _ready():
	block_instances.append(EditorBlockInstance.new(0, Vector3.ZERO, Vector3.ZERO, "TrackStraight"))
	$AddedBlocksRoot.add_child(block_instances[0].node())
	
	var tree = $CanvasLayer/Tree
	var root = tree.create_item()
	tree.hide_root = true
	var blocks_dict = {
		"Standard Blocks": ["Straight", "Straight2Pins", "Straight4Pins", "Straight6Pins", "Corner", "End"],
		"Transitions": ["ThickThickThin", "ThickThin", "ThickThinThick", "ThickThinThin"],
		"Thin Blocks": ["StraightThin", "CornerThin"]
	}
	for category in categories:
		var current_categoru_treeitem = tree.create_item(root)
		current_categoru_treeitem.set_text(0, category)
		for item in blocks_dict[category]:
			var treeitem = tree.create_item(current_categoru_treeitem)
			treeitem.set_text(0, item)
			treeitem.select(0) #Hack


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var blocklist_selected = $CanvasLayer/Tree.get_selected()
	if not blocklist_selected.get_text(0) in categories:
		GlobalVariables.block_selected = blocklist_selected.get_text(0)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not GlobalVariables.mouse_hovered:
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


func _on_place(type, pos, rot):
	block_instances.append(EditorBlockInstance.new(len(block_instances), pos, rot, type))
	$AddedBlocksRoot.add_child(block_instances[-1].node())
