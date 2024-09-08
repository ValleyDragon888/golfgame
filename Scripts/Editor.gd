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
@onready var categories = ["Special Blocks", "Standard Blocks", "Thin Blocks", "Size Transitions", "Ramps"]


func _ready():

#Instances the blocks into the dictionary
	var tree = $CanvasLayer/Tree
	var blocks_dict = {
		"Special Blocks": ["StartMarker", "EndMarker"
		],
		"Standard Blocks": ["Straight", "Straight2Pins", "Straight4Pins", "Straight6Pins",
		 "Corner", "CornerMedium", "CornerLarge",
		 "End", "Start",
			{"Ramps": ["Ramp", "RampTransitionUp", "RampTransitionDown"]}
		],
		"Size Transitions": ["ThickThickThin", "ThickThin", "ThickThinThick", "ThickThinThin"],
		"Thin Blocks": ["StraightThin", "CornerThin",
			{"Ramps": ["ThinRamp", "ThinRampTransitionUp", "ThinRampTransitionDown"]}
		],
		"Ramps": ["Ramp", "RampTransitionUp", "RampTransitionDown", "ThinRamp", "ThinRampTransitionUp", "ThinRampTransitionDown"],
		"Banked": ["BankedStraight", "BankedCorner", "BankedCornerMedium", "BankedCornerLarge", "BankedCorner2", "BankedCornerMedium2", "BankedCornerLarge2", "BankedTransitionLeft", "BankedTransitionRight"]
	}
	var root = tree.create_item()
	tree.hide_root = true
	for key in blocks_dict.keys():
		root.add_child(generate_treeitem(blocks_dict[key], key, root, tree))
		root.get_children()[-1].collapsed = true
	root.get_children()[0].select(0)

	block_instances.insert(0, EditorBlockInstance.new(0, Vector3(0, 0, 0), Vector3(0, 0, 0), "StartMarker"))
	$AddedBlocksRoot.add_child(block_instances[0].node())

#Loads the block viewing system
func generate_treeitem(dict, block_name, parent, tree) -> TreeItem:
	var treeitem = tree.create_item(parent)
	treeitem.set_text(0, block_name)
	for item in dict:
		if typeof(item) == TYPE_STRING:
			var new = tree.create_item(treeitem)
			new.set_text(0, item)
		elif typeof(item) == TYPE_DICTIONARY:
			treeitem.add_child(generate_treeitem(
				item[item.keys()[0]],
				item.keys()[0],
				treeitem,
				tree
			))
			treeitem.get_children()[-1].collapsed = true
	return treeitem

func _process(_delta):
#Block selection mechanism
	var blocklist_selected = $CanvasLayer/Tree.get_selected()
	if not blocklist_selected.get_text(0) in categories:
		GlobalVariables.block_selected = blocklist_selected.get_text(0)

#Scrolls the placement plane
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not GlobalVariables.mouse_hovered:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			y_plane.position.y += 0.5
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			y_plane.position.y -= 0.5

func set_save_path():
	save_as_dialog.popup_centered()

func save():
	var json_dict: Dictionary = {"blocks":[]}
	for block in block_instances:
		json_dict["blocks"].append(block.get_json_dict())
	var json_dict_str = JSON.stringify(json_dict, "\t")

	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		$CanvasLayer/ErrorDialog.popup_centered()
	else:
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
#This checks if text is "show blocks"
	if show_blocks_button.text == "Show Blocks":
		show_blocks_button.text = "Hide Blocks"
		blocks_ui_root.show()
	else:
		show_blocks_button.text = "Show Blocks"
		blocks_ui_root.hide()

#Linking button presses to code
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

#Block placement
func _on_place(type, pos, rot):
	if GlobalVariables.block_selected == "StartMarker":
		GlobalVariables.start_position = pos
		block_instances.remove_at(0)
		block_instances.insert(0, EditorBlockInstance.new(0, pos, rot, type))
		$AddedBlocksRoot.get_children()[0].queue_free()
		$AddedBlocksRoot.add_child(block_instances[0].node())
	else:
		block_instances.append(EditorBlockInstance.new(len(block_instances) + 1, pos, rot, type))
		$AddedBlocksRoot.add_child(block_instances[-1].node())
	print(block_instances)

#Block deletion
func _on_delete(pos):
	for j in len(block_instances):
		var block = len(block_instances) - j - 1
		var block_pos = block_instances[block].get_json_dict().position
		if not block_instances[block].get_json_dict().type == "StartMarker":
			if block_pos[0] == pos.x and block_pos[1] == pos.y and block_pos[2] == pos.z:
				block_instances.remove_at(block)
				$AddedBlocksRoot.get_children()[block].queue_free()
				break
