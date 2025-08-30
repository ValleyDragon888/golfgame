extends CharacterBody2D

var offset = Vector2.ZERO
@export var collected: Array = []
@export var activated = false

func _enter_tree():
	print(name)
	set_multiplayer_authority(name.to_int())
	if is_multiplayer_authority():
		$AuthDebug.show()
	else:
		$AuthDebug.hide()

func _physics_process(delta):
#Movement controls
	if is_multiplayer_authority():
		global_position = offset
		offset += Input.get_vector("ui_left","ui_right","ui_up","ui_down").normalized() * 300 * delta
	$VarDebug.text = str("Active:", Global.active, "         Collected:", collected)
	move_and_slide()

#Pickup item controls
	for item in len(collected):
		collected[item].global_position = lerp(collected[item].global_position,global_position,0.05)
		collected[item].gravity_scale = 0
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			activated = true
		if activated and not Global.active.has(collected[item]):
			Global.active.append(collected[item])

func _on_area_2d_body_entered(body):
#Checks to see what happens when you collide with an object
	if body.name.match("**Bomb****"):
		if Global.active.has(body) and collected.has(body):
			print("Activated")
		elif Global.active.has(body) and not collected.has(body):
			print("Exploded")
			$PlayerSprite.hide()
		elif not Global.active.has(body) and collected.has(body):
			print("Collected")
		elif not Global.active.has(body) and not collected.has(body):
			print("Not yet collected")
			collected.append(body)
