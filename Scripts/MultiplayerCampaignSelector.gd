extends Node3D

var tracks: Array[Dictionary] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_campaign_screen(name: String):
	$Title.text = "[b]Play Campaign: " + name + "[b]"
	$TracksList.clear()
	tracks = []
	var dict_tracks = GlobalVariables.campaigns[name]
	for track in dict_tracks:
		$TracksList.add_item(track.keys()[0])
		tracks.append(track)
	
	show()
	$Title.show()
	$TracksList.show()
	$Back.show()


func _on_tracks_list_item_activated(index):
	var track_path_selected = tracks[index].values()[0]
	var file = FileAccess.open(track_path_selected, FileAccess.READ)
	var contents = file.get_as_text()
	$"../..".load_file(track_path_selected)
	$"../..".rpc("update_variables", GlobalVariables.start_position, contents)
	$Panel2.hide()
	$"..".show()
	hide()
	$Back.hide()
	$Title.hide()
	$TracksList.hide()
	
