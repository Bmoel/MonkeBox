extends AnimatedSprite

"""
* Pre: First function that is called when player is instanced
* Post: Performs necessary start actions
* Return: None
"""
func _ready() -> void:
	# warning-ignore:return_value_discarded
	GlobalSignals.connect("change_position", self, "set_new_position")
	play("idle")

"""
* Pre: Called when player hits key/button
* Post: Moves player if necessary key is pressed in corresponding direction
* Return: None
"""
func _input(_event) -> void:
	var dash_pressed = Input.is_action_pressed("dash") #check if dash button pressed
	#Normal just pressed checks
	if Input.is_action_just_pressed("right",false):
		GlobalSignals.emit_signal("player_moved","right",dash_pressed)
		handle_direction("right")
		return
	elif Input.is_action_just_pressed("left",false):
		GlobalSignals.emit_signal("player_moved","left",dash_pressed)
		handle_direction("left")
		return
	elif Input.is_action_just_pressed("up",false):
		GlobalSignals.emit_signal("player_moved","up",dash_pressed)
		handle_direction("up")
		return
	elif Input.is_action_just_pressed("down",false):
		GlobalSignals.emit_signal("player_moved","down",dash_pressed)
		handle_direction("down")
		return
	#Dash and hold checks
	if dash_pressed:
		if Input.is_action_pressed("right",false):
			GlobalSignals.emit_signal("player_moved","right",dash_pressed)
			handle_direction("right")
		elif Input.is_action_pressed("left",false):
			GlobalSignals.emit_signal("player_moved","left",dash_pressed)
			handle_direction("left")
		elif Input.is_action_pressed("up",false):
			GlobalSignals.emit_signal("player_moved","up",dash_pressed)
			handle_direction("up")
		elif Input.is_action_pressed("down",false):
			GlobalSignals.emit_signal("player_moved","down",dash_pressed)
			handle_direction("down")

"""
* Pre: Called to handle when player direction changes
* Post: faces player the right way and plays right animation
* Params: direction (tells what directions player is moving)
* Return: None
"""
func handle_direction(direction:String) -> void:
	match direction:
		"right":
			play("idle")
			scale.x = 2
			scale.y = 2
		"left":
			play("idle")
			scale.x = -2
			scale.y = 2
		"up":
			play("up")
			scale.x = 2
			scale.y = 2
		"down":
			play("up")
			scale.x = 2
			scale.y = -2

"""
* Pre: Called when player moves, updates their global position
* Post: sets incoming postion
* Params: new_position (new pos for player to show at)
*		  is_down (tells if player is moving down or not)
* Return: None
"""
func set_new_position(new_position: Vector2, is_down:bool) -> void:
	position = new_position + Vector2(0,10)
	if is_down:
		position.y += 40
