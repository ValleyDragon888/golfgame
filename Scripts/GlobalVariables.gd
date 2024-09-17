extends Node

#Global variables that are accessible anywhere - use GlobalVariables.variable

var block_selected: String = "StartMarker"
var block_selected_is_scene: bool = false
var mouse_hovered: bool = false
var start_position: Vector3 = Vector3.ZERO
var current_track: String
var homescreen_mode = "HomeScreen"
var trackplayer_debug_enabled = true
var trackplayer_requested_scene_load = ""
var editor_end_block_position = Vector3(0, 0, -4)

var home = preload("res://Scenes/Home.tscn")
var editor = preload("res://Scenes/Editor.tscn")
var trackplayer = preload("res://Scenes/TrackPlayer.tscn")

const scene_blocks = ["MovingPiece"]
const campaigns = {
	"Main Campaign": [
		{"1": "res://Tracks/JSON/Mega Track"}
	]
}
