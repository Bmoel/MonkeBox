extends Node2D

#ONREADY VARS
onready var board = $Board
onready var score = $Score
onready var player = $Monkey
onready var timers = $Timers
onready var SpecialTimer = $Timers/SpecialPitfallTimer
onready var ResetTimer = $Timers/ResetBoardTimer
onready var PitfallTimer = $Timers/PitfallTimer

#CONSTANTS
const POWERUP_AMMOUNT = 50
const LIVE_AMOUNT = 5
const BANANA_BUFFER = Vector2(0,20)
const RESET_TIME_CAP = 65
const SPECIAL_TIME_CAP = 9
const PITFALL_TIME_CAP = 1

#GLOBALS
var _total_points: int = 0 #track how many points player has gotten
var _score_popup = preload("res://Scenes/ScoreEnd.tscn")
var _instr_popup = preload("res://Scenes/Instructions.tscn")
var _banana_objects: Dictionary = {} #Hold position plus objects of banana powerups
var _reset_text_timer_tracker:float = 0.0 #tracks how much time has passed for auto timer

"""
* Pre: Called when base game is initialized
* Post: Initializes necessary components
* Return: None
"""
func _ready() -> void:
	if not GlobalSignals.PlayInstructions:
		instructions_done()
		return
	GlobalSignals.PlayInstructions = false
	board.hide()
	player.hide()
	score.hide()
	var instr = _instr_popup.instance()
	add_child(instr)
	instr.popup_exclusive = true
	instr.connect("start_game", self, "instructions_done")
	instr.popup_centered()

func instructions_done() -> void:
	randomize()
	board.show()
	player.show()
	score.show()
	for tmr in timers.get_children():
		tmr.start()
	$Music/ArcadePuzzler.play()
	board.gen_rand_player_pos() #spawn player randomly
	board.connect("game_over", self, "_end_game")
	board.connect("hit_powerup", self, "_gib_pwr_points")
	board.connect("spawn_banana", self, "_banana_spawn")
	update_score(0) #initialize game score tracker

"""
* Pre: Called when points earned, update text
* Post: changes score text to new total score
* Params: new_points (integer of points to add to total)
* Return: None
"""
func update_score(new_points:int) -> void:
	_total_points += new_points
	score.text = "Score: " + str(_total_points)
	$Score.rect_position.x = get_viewport().size.x / 2 - 100
	$Score.rect_position.x -= (5 * (len(str(_total_points)) - 1))
	$Score.rect_position.y = 50

"""
* Pre: Called when timer hits 0
* Post: spawns banana randomly on board
* Return: None
"""
func _on_BananaTimer_timeout() -> void:
	board.spawn_banana()

"""
* Pre: Called when timer hits 0
* Post: spawns pitfall trap on a floor tile
* Return: None
"""
func _on_PitfallTimer_timeout() -> void:
	board.spawn_pitfall()

"""
* Pre: Called when timer hits 0
* Post: Gives extra points for surviving
* Return: None
"""
func _on_SpecialPitfallTimer_timeout():
	board.spawn_special_pitfall()

"""
* Pre: Called when timer hits 0
* Post: Makes board blank and resets (also harder MUHAHAHA)
* Return: None
"""
func _on_ResetBoardTimer_timeout():
	$SFX/SynthChime7.play()
	board.reset_board()
	#SpecialTimer
	SpecialTimer.wait_time -= 2
	if SpecialTimer.wait_time < SPECIAL_TIME_CAP:
		SpecialTimer.wait_time = SPECIAL_TIME_CAP
	SpecialTimer.start()
	#ResetTimer
	ResetTimer.wait_time += 10
	if ResetTimer.wait_time > RESET_TIME_CAP:
		ResetTimer.wait_time = RESET_TIME_CAP
	ResetTimer.start()
	#Pitfall Timer
	PitfallTimer.wait_time -= 0.2
	if PitfallTimer.wait_time < PITFALL_TIME_CAP:
		PitfallTimer.wait_time = PITFALL_TIME_CAP
	#Reset text blink stuff
	$Reset.show()
	var txtBlinkTmr = Timer.new()
	txtBlinkTmr.wait_time = 0.3
	txtBlinkTmr.one_shot = false
	txtBlinkTmr.autostart = true
	txtBlinkTmr.connect("timeout", self, "_blink_reset_text", [txtBlinkTmr])
	add_child(txtBlinkTmr)

"""
* Pre: Called when timer hits 0
* Post: Gives extra points for surviving
* Return: None
"""
func _on_AliveTimer_timeout():
	update_score(LIVE_AMOUNT)

"""
* Pre: Called when player hits a banana powerup
* Post: adds more points to score
* Params: loc (Vector2 location on board)
* Return: None
"""
func _gib_pwr_points(loc:Vector2) -> void:
	$SFX/PowerUp18.play()
	if _banana_objects.has(loc):
		_banana_objects[loc].queue_free()
		# warning-ignore:return_value_discarded
		_banana_objects.erase(loc)
	update_score(POWERUP_AMMOUNT)

"""
* Pre: Called when a banana powerup needs to be spawned
* Post: adds powerup to field
* Params: banana_obj (object with sprite)
*		  loc (Vector2 location on board)
* Return: None
"""
func _banana_spawn(banana_obj, loc:Vector2) -> void:
	_banana_objects[loc] = banana_obj
	add_child(banana_obj)
	banana_obj.position = loc + BANANA_BUFFER

func _blink_reset_text(tmr:Timer) -> void:
	_reset_text_timer_tracker += 0.3
	if _reset_text_timer_tracker == 1.2:
		$Reset.hide()
		_reset_text_timer_tracker = 0.0
		tmr.disconnect("timeout", self, "_blink_reset_text")
		tmr.queue_free()
		return
	else:
		if $Reset.modulate.a8 == 195:
			$Reset.modulate.a8 = 0
		else:
			$Reset.modulate.a8 = 195

"""
* Pre: Called when player died
* Post: Ends the game, sets point screen
* Return: None
"""
func _end_game() -> void:
	board.queue_free()
	timers.queue_free()
	score.queue_free()
	player.queue_free()
	var score_tab_inst = _score_popup.instance()
	add_child(score_tab_inst)
	score_tab_inst.set_score(_total_points)
	score_tab_inst.popup_exclusive = true
	score_tab_inst.popup_centered()
