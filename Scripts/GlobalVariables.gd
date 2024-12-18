extends Node

#Global variables that are accessible anywhere - use GlobalVariables.variable

var block_selected: String = "StartMarker"
var block_selected_is_scene: bool = false
var mouse_hovered: bool = false
var dialog_open: bool = false
var start_position: Vector3 = Vector3.ZERO
var end_position: Vector3 = Vector3(0, 0, 5)
var current_track: String
var homescreen_mode = "HomePage"
var trackplayer_debug_enabled = true
var trackplayer_requested_scene_load = ""
var checkpoints = []
var checkpoint_to_delete = [0, false]
var finished = false
var started = false
var player_name = ""

var local_multiplayer_player_details = []
var LAN_player_names: Array = []

var homepage = preload("res://Scenes/HomePage.tscn")
var playpage = preload("res://Scenes/PlayPage.tscn")
var editor = preload("res://Scenes/Editor.tscn")
var trackplayer = preload("res://Scenes/TrackPlayer.tscn")

const scene_blocks = ["MovingPiece"]
const campaigns = {
	"Main Campaign": [
		{"1 - Introduction": "res://Tracks/JSON/MainCampaign/01.json"},
		{"2 - Not a Straight Line": "res://Tracks/JSON/MainCampaign/02TurnsRocks.json"},
		{"3 - Banked Turns": "res://Tracks/JSON/MainCampaign/03Banked.json"},
		{"4 - Ramps & Turns": "res://Tracks/JSON/MainCampaign/04Ramps.json"},
		{"Eternity Gate": "res://Tracks/JSON/MainCampaign/Eternity-Gate.json"}
	]
}
const balls = ["PerfectSphere", "LowPoly1", "LowPoly2", "Cube", "TorusBall", "VoxelBall", "GearBall", "Realistic"]
var ball_selected = 0
