extends Node

#Global variables that are accessible anywhere - use GlobalVariables.variable

var block_selected: String = "StartMarker"
var block_selected_is_scene: bool = false
var mouse_hovered: bool = false
var start_position: Vector3 = Vector3.ZERO
var current_track: String
var homescreen_mode = "HomeScreen"

var home = preload("res://Scenes/Home.tscn")
var editor = preload("res://Scenes/Editor.tscn")

const scene_blocks = ["MovingPiece"]
const campaigns = {
	"Main Campaign": [
		{"1": "res://Tracks/JSON/Mega Track"}
	]
}
