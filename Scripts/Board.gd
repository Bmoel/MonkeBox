extends Node2D

signal game_over() #emitted when player has died
signal hit_powerup() #player stepped on powerup

#CONSTANTS
const NUM_SQUARES = 100
const RECT_SIZE = Vector2(45,45)
const INIT_POS = Vector2(400,180)
const ROW_COLS = 10
const SPRITE_BUF = 22

#GLOBAL VARS
var _current_position: int = 0 #current position of player
var _alive_boards: Array = [] #board status to tell if player can step on board or not
var _saved_positions: Array = [] #Vector2s of all possible positions player can be
var _banana_locations: Array = [] #Places on board where player can find powerups
var _color_rects: Array = [] #array to hold all color rects so can be changed later

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
	GlobalSignals.emit_signal("change_position", board_pos)
	check_events(_current_position)

"""
* Pre: Called when player has moved
* Post: Tracks if events are happening in game
* Return: None
"""
func check_events(pos:int) -> void:
	#Power up check
	if pos in _banana_locations:
		_banana_locations.erase(pos)
		_color_rects[_current_position].color = Color.whitesmoke
		emit_signal("hit_powerup")
	#End game check
	elif not (_current_position in _alive_boards):
		emit_signal("game_over")

"""
* Pre: Called when timer hits 0 in BaseGame.gd
* Post: Spawns banana powerup for player to get
* Return: None
"""
func spawn_banana() -> void:
	var pwrup_loc = randi() % len(_alive_boards)
	_banana_locations.append(pwrup_loc)
	_color_rects[pwrup_loc].color = Color.yellow

"""
* Pre: Called when timer hits 0 in BaseGame.gd
* Post: Spawns a pitfall that player should avoid
* Return: None
"""
func spawn_pitfall() -> void:
	var pit = randi() % len(_alive_boards)
	_alive_boards.erase(pit)
	_color_rects[pit].color = Color.black

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
	GlobalSignals.emit_signal("change_position", board_pos)
