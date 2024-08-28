extends Node3D

@onready var show_blocks_button = $CanvasLayer/ShowHideButton
@onready var blocks_ui_showing = false
@onready var blocks_ui_root = $CanvasLayer/ItemList
@onready var block_selected: String = "TrackStraight"
@onready var z_plane = $Plane 
@export var valid_blocks = [
		"TrackStraight",
		"TrackCornerSharp"
	]

# Called when the node enters the scene tree for the first time.
func _ready():
	for block in valid_blocks:
		blocks_ui_root.add_item(block)
	blocks_ui_root.select(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_block(type: String, pos:Vector3, rot:Vector3 = Vector3.ZERO):
	var new_block = MeshInstance3D.new()
	new_block.mesh = load("res://Assets/TrackEditor/{type}.obj".format({"type": type}))
	new_block.position = pos
	new_block.rotation = rot
	$AddedBlocksRoot.add_child(new_block)
	
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			# Why. WHY IS GODOT Z = Y NOOOOOOOO
			z_plane.position.y += 0.1
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			# Sanity levels just dropped
			z_plane.position.y -= 0.1


func _on_show_hide_button_pressed():
	# lazy. this checks if text is "show blocks"
	if show_blocks_button.text[0] == "S":
		show_blocks_button.text = "Hide Blocks"
		blocks_ui_root.show()
	else:
		show_blocks_button.text = "Show Blocks"
		blocks_ui_root.hide()


func _on_item_list_item_selected(index):
	block_selected = valid_blocks[index]
	print_debug(block_selected)
