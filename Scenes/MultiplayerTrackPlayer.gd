extends Node3D

const num_players = 2
var turn = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# debug, remove later
	GlobalVariables.current_track = "res://Tracks/JSON/MainCampaign/01.json"
	
	for i in range(num_players):
		var new_player = SubViewport.new()
		new_player.size = Vector2(1024, 600)
		new_player.add_child(GlobalVariables.trackplayer.instantiate())
		new_player.name = "Player" + str(i)
		$Players.add_child(new_player)
		
	#$ViewportDisplayer.texture = ViewportTexture.new()
	#$ViewportDisplayer.texture = $Players/Player0.get_texture()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
