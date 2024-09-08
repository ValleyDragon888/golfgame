extends Node

#Global variables that are accessible anywhere - use GlobalVariables.variable

var block_selected: String = "StartMarker"
var block_selected_is_scene: bool = false
var mouse_hovered: bool = false
var start_position: Vector3 = Vector3.ZERO
var current_track: String

const scene_blocks = ["MovingPiece"]
