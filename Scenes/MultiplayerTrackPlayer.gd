extends Node3D

const num_players = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(num_players):
		var new_player = SubViewport.new()
		new_player.add_child(GlobalVariables.trackplayer.instantiate())
		new_player.name = "Player" + str(i)
		$Players.add_child(new_player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
