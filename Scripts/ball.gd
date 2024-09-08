extends RigidBody3D


const DEFAULT_ZOOM = 5
@onready var arrow = $"../ArrowPivot/Arrow"
@onready var arrow_pivot = $"../ArrowPivot"
@onready var camera_pivot_v = $"../CameraPivotV"
@onready var camera_pivot_h = $"../CameraPivotV/CameraPivotH"
@onready var spring_arm = $"../CameraPivotV/CameraPivotH/SpringArm3D"
@export var sensitivity = -0.3
@export var camera_is_locked = true
@export var zoom_speed = 0.3
var arrow_material = preload("res://Assets/ArrowMaterial.tres")
var has_velocity = false
var just_released = false


#Camera controls
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
			if spring_arm.spring_length < 3:
				spring_arm.spring_length = 3
			if spring_arm.spring_length > 20:
				spring_arm.spring_length = 20

#Snap to default zoom
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				spring_arm.spring_length = DEFAULT_ZOOM

func _physics_process(_delta):
#Locks camera and arrow to the player
	camera_pivot_v.position = position
	arrow_pivot.position = position

#May be replaced with correct controls
	if Input.is_action_just_pressed("Up") and not has_velocity:
		just_released = false
		has_velocity = true
		linear_velocity.y = arrow.position.z*-1
		linear_velocity.z = (arrow.global_position.z - global_position.z) * 10
		linear_velocity.x = (arrow.global_position.x - global_position.x) * 10
		angular_velocity = Vector3(randf()*arrow.position.z, randf()*arrow.position.z, randf()*arrow.position.z)
	if Input.is_action_just_released("Up"):
		just_released = true

	if abs(linear_velocity.x) < 0.1 and abs(linear_velocity.y) < 0.1 and abs(linear_velocity.z) < 0.1:
		has_velocity = false

	if Input.is_action_pressed("Up") and has_velocity and just_released:
		Engine.time_scale = 3
	else:
		Engine.time_scale = 1

	if has_velocity:
		arrow.visible = false
	else:
		arrow.visible = true

#Quit the game
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()

	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")

#Rotates and moves the arrow
	arrow.position.z += input_dir.y * arrow.position.z * -0.04
	arrow.position.z = clamp(arrow.position.z, -8, -0.1)

#Scale arrow at far distances to be easily visible
	arrow.scale.z = (arrow.position.z-3)/-60
	arrow.scale.x = (arrow.position.z-3)/-60
	arrow.scale.y = (arrow.position.z-3)/-60
	arrow_material.albedo_color = Color(1,1/abs(arrow.position.z),0)
	print(arrow.position.z)
