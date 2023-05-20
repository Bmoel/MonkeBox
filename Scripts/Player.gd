extends AnimatedSprite

"""
* Pre: First function that is called when player is instanced
* Post: Performs necessary start actions
* Return: None
"""
func _ready() -> void:
	# warning-ignore:return_value_discarded
	GlobalSignals.connect("change_position", self, "set_position")
	play("idle")

"""
* Pre: Called when player hits key/button
* Post: Moves player if necessary key is pressed in corresponding direction
* Return: None
"""
func _input(_event) -> void:
	var dash_pressed = Input.is_action_pressed("dash")
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
* Return: None
"""
func handle_direction(direction:String) -> void:
	match direction:
		"right":
			play("idle")
			scale.x = 2
		"left":
			play("idle")
			scale.x = -2
		"up":
			play("up")
			scale.x = 2
		"down":
			play("up")
			scale.x = 2

"""
* Pre: Called when player moves, updates their global position
* Post: sets incoming postion
* Return: None
"""
func set_position(new_position: Vector2) -> void:
	position = new_position
