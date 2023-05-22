extends Node2D

#SIGNALS
signal game_over() #emitted when player has died
signal hit_powerup(loc) #player stepped on powerup
signal spawn_banana(banana_obj, loc) #banana needs to be spawned

#GAME OBJECTS
var banana_img = preload("res://Scenes/BananaSprite.tscn")
var patterns = preload("res://Scripts/Patterns.gd").new()

#CONSTANTS
const NUM_SQUARES = 100
const RECT_SIZE = Vector2(45,45)
const INIT_POS = Vector2(400,180)
const ROW_COLS = 10
const SPRITE_BUF = 22

#GLOBAL VARS
var _inc_id: int = 0 #identifier for increment
var _current_position: int = 0 #current position of player
var _alive_boards: Array = [] #board status to tell if player can step on board or not
var _saved_positions: Array = [] #Vector2s of all possible positions player can be
var _banana_locations: Array = [] #Places on board where player can find powerups
var _color_rects: Array = [] #array to hold all color rects so can be changed later
var _blink_ids:Dictionary = {} #dictionary to hold location -> id

"""
* Pre: First function that is called when board is instanced
* Post: Calls necessary starter functions
* Return: None
"""
func _ready() -> void:
	position = INIT_POS
	# warning-ignore:return_value_discarded
	GlobalSignals.connect("player_moved", self, "_player_moved")
	initialize_board()

"""
* Pre: Called when board is being made
* Post: Creates board visuals and background elements
* Return: None
"""
func initialize_board() -> void:
	_current_position = 0
	#setting up board status
	for i in range(NUM_SQUARES):
		_alive_boards.append(i)
	#setting up board tiles and their positions
	for i in range(ROW_COLS):
		for j in range(ROW_COLS):
			var color_rect:ColorRect = ColorRect.new()
			color_rect.color = Color.whitesmoke
			color_rect.rect_size = RECT_SIZE
			var new_pos:Vector2 = Vector2(j*50,i*50)
			color_rect.rect_position = new_pos
			_saved_positions.append(new_pos)
			_color_rects.append(color_rect)
			add_child(color_rect)

"""
* Pre: Called when player has moved on board
* Post: changes current position and sends message back to player
* Return: None
"""
func _player_moved(direction:String, is_dash:bool) -> void:
	_current_position = get_new_position(direction, is_dash)
	var board_pos = get_vec_position(_current_position)
	var is_down = true if (direction == "down") else false
	var is_up = true if (direction == "up") else false
	GlobalSignals.emit_signal("change_position", board_pos, is_down, is_up, is_dash)
	check_events(_current_position)

"""
* Pre: Called when player has moved
* Post: Tracks if events are happening in game
* Params: idx (index of array to check AKA location on board)
* Return: None
"""
func check_events(idx:int) -> void:
	#Power up check
	if idx in _banana_locations:
		_banana_locations.erase(idx)
		emit_signal("hit_powerup", get_vec_position(idx))
	#End game check
	elif not (_current_position in _alive_boards):
		emit_signal("game_over")

"""
* Pre: Called when timer hits 0 in BaseGame.gd
* Post: Spawns banana powerup for player to get
* Return: None
"""
func spawn_banana() -> void:
	var idx = randi() % len(_alive_boards)
	if idx > len(_alive_boards):
		return
	var pwrup_loc = _alive_boards[idx]
	_banana_locations.append(pwrup_loc)
	var banana = banana_img.instance()
	emit_signal("spawn_banana", banana, get_vec_position(pwrup_loc))

"""
* Pre: Called when timer hits 0 in BaseGame.gd
* Post: Spawns a single pitfall that player should avoid
* Return: None
"""
func spawn_pitfall() -> void:
	var idx = randi() % len(_alive_boards)
	if idx > len(_alive_boards):
		return
	var pit = _alive_boards[idx]
	create_timers([pit])

"""
* Pre: Called when timer hits 0 in BaseGame.gd
* Post: Spawns a special pitfall from SpecialPatterns
* Return: None
"""
func spawn_special_pitfall() -> void:
	var special_dict = patterns.SpecialPatterns
	var types = special_dict.keys()
	var idx = randi() % len(types)
	if idx > len(_alive_boards):
		return
	var rand_type = types[idx]
	create_timers(special_dict[rand_type])

"""
* Pre: called in pitfall spawning functions
* Post: starts timers for areas that will go away eventually
* Params: locations (locations to pass into timer callback functions)
* Return: None
"""
func create_timers(locations:Array) -> void:
	var current_id = _inc_id
	for loc in locations:
		_blink_ids[loc] = _inc_id #adding to dictionary
	_inc_id += 1
	#Check if int it maxed out
	if _inc_id == 9223372036854775807:
		_inc_id = 0
	var impTimer = Timer.new()
	var blinkTimer = Timer.new()
	impTimer.one_shot = true
	impTimer.autostart = true
	impTimer.wait_time = 1.5
	blinkTimer.one_shot = false
	blinkTimer.autostart = true
	blinkTimer.wait_time = 0.25
	impTimer.connect("timeout", self, "implement_pitfalls", [locations,impTimer,blinkTimer])
	blinkTimer.connect("timeout", self, "blink_locations", [locations, current_id])
	add_child(impTimer)
	add_child(blinkTimer)

"""
* Pre: Called when timer hits 0
* Post: Makes locations that are going away blink as a warning
* Params: locations (locations to make blink)
* Return: None
"""
func blink_locations(locations:Array, id:int) -> void:
	for pit in locations:
		if _blink_ids.has(pit):
			if not (_blink_ids[pit] == id):
				continue
		if not (pit in _alive_boards):
			continue
		if _color_rects[pit].color == Color.whitesmoke:
			_color_rects[pit].color = Color.lightcoral
		else:
			_color_rects[pit].color = Color.whitesmoke
		

"""
* Pre: Called when timer hits 0
* Post: Warnings over, make all locations in array go away
* Params: locations (locations to make blink)
*		  iTmr (timer for implement pitfalls)
*		  bTmr (timer for warning blinks)
* Return: None
"""
func implement_pitfalls(locations:Array, iTmr:Timer, bTmr:Timer) -> void:
	iTmr.queue_free()
	bTmr.disconnect("timeout", self, "blink_locations")
	bTmr.queue_free()
	for pit in locations:
		if _blink_ids.has(pit):
			# warning-ignore:return_value_discarded
			_blink_ids.erase(pit)
		if _alive_boards.has(pit):
			_alive_boards.erase(pit)
		_color_rects[pit].color = Color.black
	check_events(_current_position)

func reset_board() -> void:
	_alive_boards.clear()
	_blink_ids.clear()
	for i in range(NUM_SQUARES):
		_alive_boards.append(i)
		if i > len(_color_rects):
			return
		_color_rects[i].color = Color.whitesmoke
	

"""
* Pre: Used in _player_moved
* Post: gets new position based on direction
* Return: int
"""
func get_new_position(direction:String, is_dash = false) -> int:
	var buf = 0
	if direction == "left":
		var num = _current_position % 10
		var lTest = (0 != num)
		buf = -1 if lTest else 0
		if is_dash and lTest and (1 != num):
			buf = -2
	elif direction == "right":
		var num = _current_position % 10
		var rTest = (9 != num)
		buf = +1 if rTest else 0
		if is_dash and rTest and (8 != num):
			buf = +2
	elif direction == "up":
		buf = -10 if (_current_position > 9) else 0
		if is_dash and _current_position > 19:
			buf = -20
	elif direction == "down":
		var dTest = (_current_position < 90)
		buf = +10 if dTest else 0
		if is_dash and (_current_position < 80):
			buf = +20
	return (_current_position + buf)

"""
* Pre: Called when player is switching tile
* Post: Returns the Vector2 position of where tile is
* Return: Vector2
"""
func get_vec_position(arr_pos:int) -> Vector2:
	assert(arr_pos < len(_saved_positions))
	var x = _saved_positions[arr_pos].x + INIT_POS.x + SPRITE_BUF
	var y = _saved_positions[arr_pos].y + INIT_POS.y
	return Vector2(x,y)

"""
* Pre: Called after board has been completely set up
* Post: Generate random place for player to start in
* Return: None
"""
func gen_rand_player_pos() -> void:
	#Generate random start position for player
	_current_position = randi() % 100
	var board_pos = get_vec_position(_current_position)
	GlobalSignals.emit_signal("change_position", board_pos, false, false, false)
