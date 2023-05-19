extends Node2D

onready var board = $Board

"""
* Pre: Called when base game is initialized
* Post: Initializes necessary components
* Return: None
"""
func _ready() -> void:
	randomize()
	board.gen_rand_player_pos()
