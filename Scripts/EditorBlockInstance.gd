extends Node

class_name EditorBlockInstance

var id: int
var pos: Vector3
var rot: Vector3
var type: String

func _init(id: int, pos: Vector3, rot: Vector3, type: String):
	self.id = id
	self.pos = pos
	self.rot = rot
	self.type = type

func node() -> MeshInstance3D:
	var new_block = MeshInstance3D.new()
	new_block.mesh = load("res://Assets/TrackEditor/{type}.obj".format({"type": self.type}))
	new_block.position = self.pos
	new_block.rotation = self.rot
	new_block.name = str(self.id) # I do not understand how float gets a .to_string() fn but int does not?
	return new_block

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
