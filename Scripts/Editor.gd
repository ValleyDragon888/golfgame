extends Node3D

@onready var show_blocks_button = $CanvasLayer/ShowHideButton
@onready var blocks_ui_showing = false
@onready var blocks_ui_root = $CanvasLayer/ItemList
@onready var block_selected: String = "TrackStraight"
@onready var z_plane = $Plane
@onready var block_instances: Array[EditorBlockInstance] = []
@onready var save_path = ""
@onready var save_as_dialog = $CanvasLayer/SaveAsDialog
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
			z_plane.position.y += 0.1
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			# Sanity levels just dropped
			z_plane.position.y -= 0.1

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
