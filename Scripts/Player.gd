extends AnimatedSprite

"""
* Pre: First function that is called when player is instanced
* Post: Performs necessary start actions
* Return: None
"""
func _ready() -> void:
	# warning-ignore:return_value_discarded
	GlobalSignals.connect("change_position", self, "set_position")

"""
* Pre: Called when player hits key/button
* Post: Moves player if necessary key is pressed in corresponding direction
* Return: None
"""
func _input(_event) -> void:
	if Input.is_action_just_pressed("right",false):
		GlobalSignals.emit_signal("player_moved","right")
	elif Input.is_action_just_pressed("left",false):
		GlobalSignals.emit_signal("player_moved","left")
	elif Input.is_action_just_pressed("up",false):
		GlobalSignals.emit_signal("player_moved","up")
	elif Input.is_action_just_pressed("down",false):
		GlobalSignals.emit_signal("player_moved","down")

"""
* Pre: Called when player moves, updates their global position
* Post: sets incoming postion
* Return: None
"""
func set_position(new_position: Vector2) -> void:
	position = new_position
