extends Node3D

@onready var mode = "HomeScreen"
@onready var mouse_position_y
@onready var editor = preload("res://Scenes/Editor.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#$Background/CameraOrigin.rotation_degrees.y += 10 * delta
	#$Background/CameraOrigin/Camera3D.look_at($Background/CameraOrigin.position)
	#$Background/CameraOrigin.rotation_degrees.x = lerp($Background/CameraOrigin.rotation_degrees.x, mouse_position_y, 0.01)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position_y = (event.global_position.y / get_viewport().size.y * 20) - 20
func _on_play_credits_pressed():
	mode = "Credits"
	$HomeScreen.hide()
	$Credits.show()


func _on_back_pressed():
	mode = "HomeScreen"
	$Credits.hide()
	$HomeScreen.show()


func _on_editor_pressed():
	get_tree().change_scene_to_packed(editor)
	
