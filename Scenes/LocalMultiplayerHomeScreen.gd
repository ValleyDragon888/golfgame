extends Node3D

@onready var mouse_position_y
@onready var state = "numplayers"
var current_details_player = 1
var player_details_ball_selected = 0
var num_players = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/NumPlayers.show()
	$CanvasLayer/PlayerDetails.hide()


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
	
	$CanvasLayer/PlayerDetails/BallSelector/HBoxContainer/SubViewportContainer/SubViewport/Ball3dModel.rotate_y(-(delta)/2)


func update_num_players():
	$CanvasLayer/NumPlayers/VBoxContainer/HBoxContainer/NumberDisplay.text = " " + str(num_players) + " "

func player_details_setup():
	$CanvasLayer/PlayerDetails/EnterNameLabel.text = "Enter Name, Player " + str(current_details_player)

func _on_less_pressed():
	num_players -= 1
	if num_players < 2: num_players = 2
	update_num_players()


func _on_more_pressed():
	num_players += 1
	update_num_players()


func _on_next_pressed():
	state = "playerdetails"
	$CanvasLayer/NumPlayers.hide()
	$CanvasLayer/PlayerDetails.show()


func _on_last_ball_pressed():
	player_details_ball_selected -= 1
	if player_details_ball_selected < 0:
		player_details_ball_selected = len(GlobalVariables.balls)-1
	change_ball()


func _on_next_ball_pressed():
	player_details_ball_selected += 1
	if player_details_ball_selected > len(GlobalVariables.balls)-1:
		player_details_ball_selected = 0
	change_ball()

func change_ball():
	$CanvasLayer/PlayerDetails/BallSelector/HBoxContainer/SubViewportContainer/SubViewport/Ball3dModel.mesh = load("res://Assets/Balls/"+str(GlobalVariables.balls[player_details_ball_selected])+".obj")
