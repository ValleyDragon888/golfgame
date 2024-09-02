extends Node3D

#Instance and import variables
@onready var camera_pivot_v = $CameraPivotV
@onready var camera_pivot_h = $CameraPivotV/CameraPivotH
@onready var spring_arm_3d = $SpringArm3D
@onready var mesh_instance_3d = $SpringArm3D/MeshInstance3D

var sensitivity = -0.3
const SPEED = 3
var velocity = Vector3.ZERO

func _process(delta):
#Moves the camera
	var direction = Input.get_vector("DevLeft", "DevRight", "DevUp", "DevDown")
	direction = (camera_pivot_v.transform.basis * Vector3(direction.x, Input.get_axis("DevSneak", "DevJump"), direction.y)).normalized()
	
	if direction:
		velocity.x = direction.x * delta * SPEED
		velocity.y = direction.y * delta * SPEED
		velocity.z = direction.z * delta * SPEED
	else:
		velocity.x *= 0.95
		velocity.y *= 0.95
		velocity.z *= 0.95
		
	position.x += velocity.x
	position.y += velocity.y
	position.z += velocity.z

#Rotates the spring arm
	spring_arm_3d.rotation.x = camera_pivot_h.rotation.x * -1
	spring_arm_3d.rotation.y = deg_to_rad(rad_to_deg(camera_pivot_v.rotation.y) + 180)
	print(mesh_instance_3d.global_position)
	
#Quits the game
	if Input.is_action_just_pressed("DevQuit"):
		get_tree().quit()
	
func _input(event):
#Rotates the camera
	if Input.is_mouse_button_pressed(2):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if event is InputEventMouseMotion:
			camera_pivot_v.rotate_y(deg_to_rad(event.relative.x * sensitivity))
			camera_pivot_h.rotate_x(deg_to_rad(event.relative.y * sensitivity))
			camera_pivot_h.rotation.x = clamp(camera_pivot_h.rotation.x, deg_to_rad(-90), deg_to_rad(90))	
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
