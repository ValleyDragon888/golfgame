extends CharacterBody3D


#Instance and import variables
const SPEED = 5.0
const FRICTION = 1
const JUMP_VELOCITY = 10

@onready var ball = $Ball
@onready var camera_pivot = $CameraPivot
@onready var spring_arm = $CameraPivot/SpringArm3D
@export var sensitivity = -0.3
@export var camera_is_locked = false
@export var zoom_speed = 0.3
@export var default_zoom = 5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


#Camera controls
func _input(event):
	if Input.is_mouse_button_pressed(2) or camera_is_locked:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(event.relative.x * sensitivity))
			camera_pivot.rotate_x(deg_to_rad(event.relative.y * sensitivity))
			camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
			ball.rotate_y(deg_to_rad(event.relative.x * sensitivity * -1))
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if Input.is_action_just_pressed("LockCamera") and camera_is_locked == false:
		camera_is_locked = true
	elif Input.is_action_just_pressed("LockCamera") and camera_is_locked == true:
		camera_is_locked = false
		
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				spring_arm.spring_length += zoom_speed * spring_arm.spring_length
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				spring_arm.spring_length -= zoom_speed * spring_arm.spring_length
			# Snap to default zoom
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				spring_arm.spring_length = default_zoom
			
func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	#Will be replaced with correct controls
	if Input.is_action_just_pressed("DevJump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("DevQuit"):
		get_tree().quit()

	var input_dir = Input.get_vector("DevLeft", "DevRight", "DevUp", "DevDown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/FRICTION)
		velocity.z = move_toward(velocity.z, 0, SPEED/FRICTION)
	
	#Rotates the ball - need to fix rotating when collided
	ball.rotate_z(deg_to_rad(input_dir.x*SPEED*-1))
	ball.rotate_x(deg_to_rad(input_dir.y*SPEED))

	move_and_slide()
