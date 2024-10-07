extends Node3D

@onready var mouse_position_y
@onready var UI_ball_pos = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Background/CameraOrigin.rotation_degrees.y += 10 * delta
	$Background/CameraOrigin/Camera3D.look_at($Background/CameraOrigin.position)
	var y = 0
	if mouse_position_y == null:
		y = 0.0
	else:
		y = mouse_position_y
	$Background/CameraOrigin.rotation_degrees.x = lerp($Background/CameraOrigin.rotation_degrees.x, y, 0.01)
	$PlayScreen/Path2D/PathFollow2D.progress_ratio = lerp($PlayScreen/Path2D/PathFollow2D.progress_ratio, UI_ball_pos, 0.03)
	
	$PlayScreen/SubViewport/Ball3dModel.rotate_y(-(delta)/2)
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_position_y = (event.global_position.y / get_viewport().size.y * 20) - 20
func _on_credits_pressed():
	GlobalVariables.homescreen_mode = "Credits"
	$PlayScreen.hide()
	$Credits.show()
	UI_ball_pos = 1.0


func _on_editor_pressed():
	get_tree().change_scene_to_packed(GlobalVariables.editor)
	UI_ball_pos = 1.0


func _on_campaign_pressed():
	GlobalVariables.homescreen_mode = "CampaignSelect"
	$CampaignSelector.show_campaign_screen("Main Campaign")
	$PlayScreen.hide()
	UI_ball_pos = 1.0


func _on_campaign_select_back_pressed():
	$CampaignSelector.hide()
	$CampaignSelector/Back.hide()
	$CampaignSelector/Title.hide()
	$CampaignSelector/TracksList.hide()
	$PlayScreen.show()
	UI_ball_pos = 0.15
	$PlayScreen/Path2D/PathFollow2D.progress_ratio = 0.15

func _on_back_pressed():
	GlobalVariables.homescreen_mode = "HomePage"
	get_tree().change_scene_to_packed(GlobalVariables.homepage)
	UI_ball_pos = 1.0

func _on_campaign_mouse_entered():
	UI_ball_pos = 0.22

func _on_editor_mouse_entered():
	UI_ball_pos = 0.7
