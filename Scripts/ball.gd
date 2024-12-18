extends RigidBody3D

const DEFAULT_ZOOM = 5
@onready var arrow = $"../ArrowPivot/Arrow"
@onready var arrow_pivot = $"../ArrowPivot"
@onready var camera_pivot_v = $"../CameraPivotV"
@onready var camera_pivot_h = $"../CameraPivotV/CameraPivotH"
@onready var spring_arm = $"../CameraPivotV/CameraPivotH/SpringArm3D"
@onready var shot_indicator = $"../CanvasLayer/ShotIndicator"
@onready var hit_particles = $"../CameraPivotV/Hit Particles"
@onready var ball_mesh = $BallMesh
@export var sensitivity = -0.3
@export var camera_is_locked = true
@export var zoom_speed = 0.3
var arrow_material = preload("res://Assets/ArrowMaterial.tres")
var has_velocity = false
var just_released = false
var shots = 0
#LocalMultiplayer variables
var local_multiplayer_enabled: bool = false
var multiplayer_master = ""
var has_shot = false
var player_name = ""
@export var is_child = false
@export var is_disabled = false


func _ready():
	ball_mesh.mesh = load("res://Assets/Balls/"+str(GlobalVariables.balls[GlobalVariables.ball_selected])+".obj")
	multiplayer_master = get_tree().root.get_child(2)
	
func _input(event):
#Camera movement
	if Input.is_action_just_pressed("LockCamera") and camera_is_locked == false:
		camera_is_locked = true
	elif Input.is_action_just_pressed("LockCamera") and camera_is_locked == true:
		camera_is_locked = false

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or camera_is_locked:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if event is InputEventMouseMotion:
			camera_pivot_v.rotate_y(deg_to_rad(event.relative.x * sensitivity))
			camera_pivot_h.rotate_x(deg_to_rad(event.relative.y * sensitivity))
			camera_pivot_h.rotation.x = clamp(camera_pivot_h.rotation.x, deg_to_rad(-90), deg_to_rad(45))
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			arrow_pivot.rotation.y = camera_pivot_v.rotation.y
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

#Camera zoom
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				spring_arm.spring_length += zoom_speed * spring_arm.spring_length
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				spring_arm.spring_length -= zoom_speed * spring_arm.spring_length

#Clamps camera zoom
			spring_arm.spring_length = clamp(spring_arm.spring_length, 3, 30)

#Snap to default zoom
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				spring_arm.spring_length = DEFAULT_ZOOM

func _physics_process(_delta):
#Locks camera and arrow to the player
	if not GlobalVariables.finished:
		camera_pivot_v.position = lerp(camera_pivot_v.position, position, 0.1 * Engine.time_scale)
	arrow_pivot.position = position
#Checks if the player is within 1 block of the end
	var dist_to_end = abs(global_position - (GlobalVariables.end_position * 6))
	if dist_to_end.x < 1 and dist_to_end.y < 3 and dist_to_end.z < 1 and len(GlobalVariables.checkpoints) == 0 and linear_velocity.x < 0.2 and linear_velocity.z < 0.2:
		print("Finished!")
		if not local_multiplayer_enabled:
			hide()
			arrow.hide()
			camera_is_locked = false
			$"../CameraPivotV/GPUParticles3D".emitting = true
			GlobalVariables.finished = true
		else:
			print(player_name)
			multiplayer_master.finished(player_name, shots)
		
#Checks if player is within 3 blocks of a checkpoint
	for item in len(GlobalVariables.checkpoints):
		var dist_to_checkpoint = Vector3(abs(global_position.x - (GlobalVariables.checkpoints[item].x * 6)),abs(global_position.y - (GlobalVariables.checkpoints[item].y * 6)),abs(global_position.z - (GlobalVariables.checkpoints[item].z * 6)))
		if dist_to_checkpoint.x < 3 and dist_to_checkpoint.y < 6 and dist_to_checkpoint.z < 3:
			print("Checkpoint!")
#Then removes it from the variable
			GlobalVariables.checkpoint_to_delete[0] = GlobalVariables.checkpoints[item].w
			GlobalVariables.start_position.x = GlobalVariables.checkpoints[item].x * 6
			GlobalVariables.start_position.y = GlobalVariables.checkpoints[item].y * 6
			GlobalVariables.start_position.z = GlobalVariables.checkpoints[item].z * 6
			GlobalVariables.checkpoint_to_delete[1] = true
			GlobalVariables.checkpoints.remove_at(item)
			break
	
	if has_shot and not has_velocity and not is_disabled and local_multiplayer_enabled:
		print("goto next tuen")
		multiplayer_master.next_turn()

	if not local_multiplayer_enabled:
		is_disabled = false
	if Input.is_action_just_pressed("Up") and not has_velocity and not GlobalVariables.finished and not is_disabled:
		has_shot = true
		just_released = false
		GlobalVariables.start_position = global_position
		linear_velocity.y = arrow.position.z*-1
		linear_velocity.z = (arrow.global_position.z - global_position.z) * 10
		linear_velocity.x = (arrow.global_position.x - global_position.x) * 10
		angular_velocity = Vector3(randf()*arrow.position.z, randf()*arrow.position.z, randf()*arrow.position.z)
		shots += 1
		shot_indicator.text = "Shots: " + str(shots)
		hit_particles.scale = Vector3(arrow.position.z, arrow.position.z, arrow.position.z)
		hit_particles.emitting = true
		#print(shots)
	if Input.is_action_just_released("Up"):
		just_released = true

	if abs(linear_velocity.x) < 0.1 and abs(linear_velocity.y) < 0.1 and abs(linear_velocity.z) < 0.1: 
		has_velocity = false
	else:
		has_velocity = true

	if Input.is_action_pressed("Up") and has_velocity and just_released and not GlobalVariables.finished:
		Engine.time_scale = 3
		$"../FastForward".visible = true
	else:
		$"../FastForward".visible = false
		Engine.time_scale = 1

	if has_velocity:
		arrow.hide()
	elif not GlobalVariables.finished:
		arrow.show()

	if position.y < -20:
		position = GlobalVariables.start_position
		position.y = GlobalVariables.start_position.y + 5
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
#Quit the game
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()

	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")

#Rotates and moves the arrow, and progress bar
	arrow.position.z += input_dir.y * arrow.position.z * -0.04
	arrow.position.z = clamp(arrow.position.z, -8, -0.1)
	$"../CanvasLayer/PowerIndicator".value = -8 - arrow.position.z
	$"../CanvasLayer/PowerIndicator".modulate = Color(1,1/abs(arrow.position.z*0.5),0)

#Scale arrow at far distances to be easily visible
	arrow.scale.z = (arrow.position.z-3)/-60
	arrow.scale.x = (arrow.position.z-3)/-60
	arrow.scale.y = (arrow.position.z-3)/-60
	arrow_material.albedo_color = Color(1,1/abs(arrow.position.z*0.5),0)

func disable():
	is_disabled = true
	
func enable():
	is_disabled = false
	has_shot = false
