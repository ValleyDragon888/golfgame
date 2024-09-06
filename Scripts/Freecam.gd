extends Node3D

signal place(type: String, pos: Vector3, rot: Vector3)
signal delete(pos: Vector3)

#Instance and import variables
@onready var camera_pivot_v = $CameraPivotV
@onready var camera_pivot_h = $CameraPivotV/CameraPivotH
@onready var tile_detector = $TileDetector
@onready var tile_indicator = $TileIndicator
@onready var tile_detector_end = $TileDetector/TileDetectorEnd
@onready var y_plane = $"../YPlane"

var sensitivity = -0.3
const SPEED = 3
var velocity = Vector3.ZERO
var tile_pos = Vector3.ZERO
var type = "TrackStraight"

func _process(delta):
#Moves the camera
	var direction = Input.get_vector("Left", "Right", "Forward", "Backward")
	direction = (camera_pivot_v.transform.basis * Vector3(direction.x, Input.get_axis("Down", "Up"), direction.y)).normalized()
	if GlobalVariables.mouse_hovered:
		direction = Vector3.ZERO

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

#Rotates the tile detector
	tile_detector.rotation.x = camera_pivot_h.rotation.x * -1
	tile_detector.rotation.y = deg_to_rad(rad_to_deg(camera_pivot_v.rotation.y) + 180)

#Snaps the tile_pos to 1x1 grid
	tile_pos.x = snapped(tile_detector_end.global_position.x, 1)
	tile_pos.y = y_plane.global_position.y
	tile_pos.z = snapped(tile_detector_end.global_position.z, 1)

	if tile_detector.spring_length == tile_detector.get_hit_length():
		tile_indicator.visible = false
	else:
		tile_indicator.global_position = tile_pos
		tile_indicator.visible = true
		tile_indicator.mesh = load("res://Assets/TrackEditor/{type}.obj".format({"type": type}))
		if Input.is_action_just_pressed("PlaceBlock") and not GlobalVariables.mouse_hovered:
			place.emit(type, tile_pos, tile_indicator.rotation)
		#print(tile_pos)
		if Input.is_action_just_pressed("DeleteBlock") and not GlobalVariables.mouse_hovered:
			delete.emit(tile_pos)
	type = GlobalVariables.block_selected

#Quits the game
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()

#Prevents moving while popup is open
	if $"../CanvasLayer/LoadDialog".visible or $"../CanvasLayer/LoadFileSelectorDialog".visible or $"../CanvasLayer/SaveAsDialog".visible:
		GlobalVariables.mouse_hovered = true

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

	if Input.is_action_just_pressed("RotateTrackPieceLeft"):
		tile_indicator.rotation_degrees.y += 90
	if Input.is_action_just_pressed("RotateTrackPieceRight"):
		tile_indicator.rotation_degrees.y -= 90

#Manages hovering while placing problems
func _on_control_mouse_exited():
	GlobalVariables.mouse_hovered = true
func _on_control_mouse_entered():
	GlobalVariables.mouse_hovered = false
