extends Node3D

@onready var camera_pivot_v = $CameraPivotV
@onready var camera_pivot_h = $CameraPivotV/CameraPivotH
var sensitivity = 0.3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input_dir = Input.get_vector("DevLeft", "DevRight", "DevUp", "DevDown")
	
func _input(event):
	if Input.is_mouse_button_pressed(2):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if event is InputEventMouseMotion:
			camera_pivot_v.rotate_y(deg_to_rad(event.relative.x * sensitivity))
			camera_pivot_h.rotate_x(deg_to_rad(event.relative.y * sensitivity))
			camera_pivot_h.rotation.x = clamp(camera_pivot_h.rotation.x, deg_to_rad(-90), deg_to_rad(45))	
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
