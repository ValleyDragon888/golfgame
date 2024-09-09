extends Node3D

@onready var mode = "HomeScreen"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Background/Path3D/PathFollow3D.progress += delta
	$Background/Path3D/PathFollow3D/Camera3D.look_at($Background/MeshInstance3D.position)

func _on_play_credits_pressed():
	mode = "Credits"
	$HomeScreen.hide()
	$Credits.show()


func _on_back_pressed():
	mode = "HomeScreen"
	$Credits.hide()
	$HomeScreen.show()
