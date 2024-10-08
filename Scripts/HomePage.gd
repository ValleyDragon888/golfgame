extends Node3D

@onready var mouse_position_y
@onready var UI_ball_pos = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	$HomeScreen/SubViewportContainer/SubViewport/Ball3dModel.mesh = load("res://Assets/Balls/"+str(GlobalVariables.balls[GlobalVariables.ball_selected])+".obj")
	$HomeScreen/PlayerName.text = GlobalVariables.player_name

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
	$HomeScreen/Path2D/PathFollow2D.progress_ratio = lerp($HomeScreen/Path2D/PathFollow2D.progress_ratio, UI_ball_pos, 0.03)
	
	$HomeScreen/SubViewportContainer/SubViewport/Ball3dModel.rotate_y(-(delta)/2)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position_y = (event.global_position.y / get_viewport().size.y * 20) - 20
func _on_credits_pressed():
	GlobalVariables.homescreen_mode = "Credits"
	$HomeScreen.hide()
	$Credits.show()
	UI_ball_pos = 1.0

func _on_back_pressed():
	GlobalVariables.homescreen_mode = "HomeScreen"
	$Credits.hide()
	$HomeScreen.show()
	UI_ball_pos = 0.05
	$HomeScreen/Path2D/PathFollow2D.progress_ratio = 0.05

func _on_settings_pressed():
	#get_tree().change_scene_to_packed(GlobalVariables.settings)
	UI_ball_pos = 1.0


func _on_play_pressed():
	GlobalVariables.homescreen_mode = "PlayPage"
	UI_ball_pos = 1.0
	get_tree().change_scene_to_packed(GlobalVariables.playpage)

func _on_campaign_select_back_pressed():
	$CampaignSelector.hide()
	$CampaignSelector/Back.hide()
	$CampaignSelector/Title.hide()
	$CampaignSelector/TracksList.hide()
	$HomeScreen.show()
	UI_ball_pos = 0.05
	$HomeScreen/Path2D/PathFollow2D.progress_ratio = 0.05


func _on_play_mouse_entered():
	UI_ball_pos = 0.12


func _on_credits_mouse_entered():
	UI_ball_pos = 0.2


func _on_settings_mouse_entered():
	UI_ball_pos = 0.27


func _on_left_pressed():
	GlobalVariables.ball_selected -= 1
	if GlobalVariables.ball_selected < 0:
		GlobalVariables.ball_selected = len(GlobalVariables.balls)-1
	change_ball()


func _on_right_pressed():
	GlobalVariables.ball_selected += 1
	if GlobalVariables.ball_selected > len(GlobalVariables.balls)-1:
		GlobalVariables.ball_selected = 0
	change_ball()

func change_ball():
	print(GlobalVariables.balls[GlobalVariables.ball_selected])
	$HomeScreen/SubViewportContainer/SubViewport/Ball3dModel.mesh = load("res://Assets/Balls/"+str(GlobalVariables.balls[GlobalVariables.ball_selected])+".obj")

func _on_player_name_text_changed():
	GlobalVariables.player_name = $HomeScreen/PlayerName.text
