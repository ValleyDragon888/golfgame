extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	load_level_from_file("res://Tracks/JSON/testsave.json")

func add_track_piece(type: String, position: Vector3, rot: Vector3 = Vector3(0.0, 0.0, 0.0)):
	var mesh = MeshInstance3D.new()
	mesh.mesh = load("res://Assets/TrackEditor/{type}.obj".format({"type": type}))
	mesh.create_trimesh_collision()
	mesh.position = position
	mesh.rotation = rot
	add_child(mesh)

func process_json(jsondat: String):
	var decoded = JSON.parse_string(jsondat)
	var blocks = decoded["blocks"]
	for block in blocks:
		add_track_piece(block["type"],
		 Vector3(block["position"][0], block["position"][1], block["position"][2]),
		 Vector3(block["rotation"][0], block["rotation"][1], block["rotation"][2])
		)

func load_level_from_file(filename: String):
	var file = FileAccess.open(filename, FileAccess.READ)
	var content = file.get_as_text()
	process_json(content)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
