extends Node2D

#GLOBAL VARS
var _board_status: Array = [] #board status to tell if player can step on board or not
var _saved_positions: Array = []
var _current_position: int = 0 #current position of player

#CONSTANTS
const NUM_SQUARES = 100
const RECT_SIZE = Vector2(45,45)
const INIT_POS = Vector2(400,200)
const ROW_COLS = 10
const SPRITE_BUF = 22

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
	init_globals()
	for i in range(ROW_COLS):
		for j in range(ROW_COLS):
			var color_rect:ColorRect = ColorRect.new()
			color_rect.color = Color.whitesmoke
			color_rect.rect_size = RECT_SIZE
			var new_pos:Vector2 = Vector2(j*50,i*50)
			color_rect.rect_position = new_pos
			_saved_positions.append(new_pos)
			add_child(color_rect)

"""
* Pre: Called when board is being initialized
* Post: Sets up class's global variables
* Return: None
"""
func init_globals() -> void:
	_current_position = 0
	for _i in range(NUM_SQUARES):
		_board_status.append(1)

"""
* Pre: Called when player has moved on board
* Post: changes current position and sends message back to player
* Return: None
"""
func _player_moved(direction:String) -> void:
	_current_position = get_new_position(direction)
	var board_pos = get_vec_position(_current_position)
	GlobalSignals.emit_signal("change_position", board_pos)

"""
* Pre: Used in _player_moved
* Post: gets new position based on direction
* Return: int
"""
func get_new_position(direction:String) -> int:
	var buf = 0
	if direction == "left":
		buf = -1 if (_current_position % 10 != 0) else 0
	elif direction == "right":
		var num = _current_position % 10
		buf = +1 if (9 != num) else 0
	elif direction == "up":
		buf = -10 if (_current_position > 9) else 0
	elif direction == "down":
		buf = +10 if (_current_position < 90) else 0
	return (_current_position + buf)

"""
* Pre: Called when player is switching tile
* Post: Returns the Vector2 position of where tile is
* Return: Vector2
"""
func get_vec_position(arr_pos:int) -> Vector2:
	assert(arr_pos < len(_saved_positions))
	var x = _saved_positions[arr_pos].x + INIT_POS.x + SPRITE_BUF
	var y = _saved_positions[arr_pos].y + INIT_POS.y + SPRITE_BUF
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
