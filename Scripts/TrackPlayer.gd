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

func generate_treeitem(dict, name, parent, tree) -> TreeItem:
	var treeitem = tree.create_item(parent)
	treeitem.set_text(0, name)
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
			treeitem.get_children()[-1].uncollapse_tree()
	return treeitem

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not GlobalVariables.mouse_hovered:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			# Why. WHY IS GODOT Z = Y NOOOOOOOO
			y_plane.position.y += 1
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			# Sanity levels just dropped
			y_plane.position.y -= 1

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
