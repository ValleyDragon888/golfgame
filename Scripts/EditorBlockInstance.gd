extends Node


class_name EditorBlockInstance

var id: int
var pos: Vector3
var rot: Vector3
var type: String
var is_scene: bool


func _init(id: int, pos: Vector3, rot: Vector3, type: String):
	self.id = id
	self.pos = pos
	self.rot = rot
	self.type = type
	if self.type in GlobalVariables.scene_blocks: self.is_scene = true
	else: self.is_scene = false

func _meshinstance_node() -> MeshInstance3D:
	var new_block = MeshInstance3D.new()
	new_block.mesh = load("res://Assets/TrackEditor/{type}.obj".format({"type": self.type}))
	new_block.position = self.pos
	new_block.rotation = self.rot
	if type != "EndIndicator" and type != "StartIndicator" and type != "CheckpointMarker":
		new_block.create_trimesh_collision()
	new_block.name = str(self.id)
	return new_block

func _scene_node():
	return load("res://Assets/TrackEditor/ScenePieces/{type}.tscn".format({"type": self.type})).instantiate()
 
func node() -> Variant:
	if not self.is_scene: return self._meshinstance_node()
	else:
		var scene = Node3D.new()
		scene.position = self.pos
		scene.rotation = self.rot
		scene.name = str(self.id)
		scene.add_child(self._scene_node())
		return scene

func get_json_dict() -> Dictionary:
	return {
		"type": self.type,
		"position": [
			self.pos.x,
			self.pos.y,
			self.pos.z
		],
		"rotation": [
			self.rot.x,
			self.rot.y,
			self.rot.z
		]
	}
