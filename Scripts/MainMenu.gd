extends Control

var credits_scene = preload("res://Scenes/Credits.tscn")

func _ready() -> void:
	$Buttons/Play.grab_focus()

"""
* Pre: Play is pressed
* Post: Takes you to the main portion of the game
* Return: None
"""
func _on_Play_pressed() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/BaseGame.tscn")

"""
* Pre: Credits button is pressed
* Post: Opens up the credits popup-menu
* Return: None
"""
func _on_Credits_pressed() -> void:
	var new_credits:Popup = credits_scene.instance()
	add_child(new_credits)
	new_credits.popup_centered()

"""
* Pre: Quit button is pressed
* Post: Exits you from the game
* Return: None
"""
func _on_Quit_pressed() -> void:
	get_tree().quit()
