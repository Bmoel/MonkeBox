extends Node2D

#ONREADY VARS
onready var board = $Board
onready var score = $Score
onready var player = $Monkey
onready var timers = $Timers

#CONSTANTS
const POWERUP_AMMOUNT = 50
const LIVE_AMOUNT = 5

#GLOBALS
var _total_points: int = 0 #track how many points player has gotten

"""
* Pre: Called when base game is initialized
* Post: Initializes necessary components
* Return: None
"""
func _ready() -> void:
	randomize()
	board.gen_rand_player_pos() #spawn player randomly
	board.connect("game_over", self, "_end_game")
	board.connect("hit_powerup", self, "_gib_points")
	update_score(0) #initialize game score tracker

"""
* Pre: Called when points earned, update text
* Post: changes score text to new total score
* Return: None
"""
func update_score(new_points:int) -> void:
	_total_points += new_points
	score.text = "Score: " + str(_total_points)

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
func _on_AliveTimer_timeout():
	update_score(LIVE_AMOUNT)

"""
* Pre: Called when player hits a banana powerup
* Post: adds more points to score
* Return: None
"""
func _gib_points() -> void:
	update_score(POWERUP_AMMOUNT)

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
