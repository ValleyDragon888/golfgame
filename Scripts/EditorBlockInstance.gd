class_name CharacterStats

var id: int
var pos: Vector3
var rot: Vector3
var piece: String

func _init(id: int, pos: Vector3, rot: Vector3, piece: String):
	self.id = id
	self.pos = pos
	self.rot = rot
	self.piece = piece
