extends AnimatedSprite

#GLOBALS
var last_animation:Array = ["idle",false]

"""
* Pre: First function that is called when player is instanced
* Post: Performs necessary start actions
* Return: None
"""
func _ready() -> void:
	# warning-ignore:return_value_discarded
	GlobalSignals.connect("change_position", self, "set_new_position")
	# warning-ignore:return_value_discarded
	connect("animation_finished", self, "_ani_finished")
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
		handle_direction("right",dash_pressed)
		return
	elif Input.is_action_just_pressed("left",false):
		GlobalSignals.emit_signal("player_moved","left",dash_pressed)
		handle_direction("left",dash_pressed)
		return
	elif Input.is_action_just_pressed("up",false):
		GlobalSignals.emit_signal("player_moved","up",dash_pressed)
		handle_direction("up",dash_pressed)
		return
	elif Input.is_action_just_pressed("down",false):
		GlobalSignals.emit_signal("player_moved","down",dash_pressed)
		handle_direction("down",dash_pressed)
		return
	#Dash and hold checks
	if dash_pressed:
		if Input.is_action_pressed("right",false):
			GlobalSignals.emit_signal("player_moved","right",dash_pressed)
			handle_direction("right",dash_pressed)
		elif Input.is_action_pressed("left",false):
			GlobalSignals.emit_signal("player_moved","left",dash_pressed)
			handle_direction("left",dash_pressed)
		elif Input.is_action_pressed("up",false):
			GlobalSignals.emit_signal("player_moved","up",dash_pressed)
			handle_direction("up",dash_pressed)
		elif Input.is_action_pressed("down",false):
			GlobalSignals.emit_signal("player_moved","down",dash_pressed)
			handle_direction("down",dash_pressed)

"""
* Pre: Called to handle when player direction changes
* Post: faces player the right way and plays right animation
* Params: direction (tells what directions player is moving)
* Return: None
"""
func handle_direction(direction:String, is_dash:bool) -> void:
	match direction:
		"right":
			scale.x = 2
			scale.y = 2
			if is_dash:
				rotation_degrees = 0
				play("die")
				last_animation = ["right",true]
			else:
				rotation_degrees = 0
				play("idle")
				last_animation = ["right",false]
		"left":
			scale.x = -2
			scale.y = 2
			if is_dash:
				rotation_degrees = 0
				play("die")
				last_animation = ["left",true]
			else:
				rotation_degrees = 0
				play("idle")
				last_animation = ["left",false]
		"up":
			scale.x = 2
			scale.y = 2
			if is_dash:
				rotation_degrees = 270
				play("die")
				last_animation = ["up",true]
			else:
				rotation_degrees = 0
				play("up")
				last_animation = ["up",false]
		"down":
			scale.x = 2
			scale.y = -2
			if is_dash:
				rotation_degrees = 90
				play("die")
				last_animation = ["down",true]
			else:
				rotation_degrees = 0
				play("up")
				last_animation = ["down",false]

"""
* Pre: Called when player moves, updates their global position
* Post: sets incoming postion
* Params: new_position (new pos for player to show at)
*		  is_down (tells if player is moving down or not)
*		  is_up (tells if player is moving up)
*		  is_dash (tells if player is dashing or not)
* Return: None
"""
func set_new_position(new_position: Vector2, is_down:bool, is_up:bool, is_dash:bool) -> void:
	position = new_position + Vector2(0,10)
	if is_down:
		position.y += 40
	if is_up and is_dash:
		position.x -= 20
		position.y += 20
	if is_down and is_dash:
		position.x -= 20
		position.y -= 20

"""
* Pre: Called when an animation finishes 
* Post: adjusts player animations/positions
* Return: None
"""
func _ani_finished() -> void:
	rotation_degrees = 0
	if last_animation[0] == "right" or last_animation[0] == "left":
		play("idle")
	elif last_animation[0] == "up":
		play("up")
		if last_animation[1]:
			position.x += 20
			position.y -= 20
			last_animation[1] = false
	elif last_animation[0] == "down":
		play("up")
		if last_animation[1]:
			position.x += 20
			position.y += 20
			last_animation[1] = false
