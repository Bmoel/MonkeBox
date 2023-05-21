extends Control

var credits_scene = preload("res://Scenes/Credits.tscn")
var options_scene = preload("res://Scenes/Options.tscn")

func _ready() -> void:
	# warning-ignore:return_value_discarded
	GlobalSignals.connect("unselect_credits_button", self, "_credits_focus")
	#Set initial audios
	for i in range(0,3):
		if i == 0:
			AudioServer.set_bus_volume_db(i,0)
		else:
			AudioServer.set_bus_volume_db(i,-4)
	#Setup menu objects
	$CanvasLayer/CenterContainer/Buttons/Play.grab_focus()
	$MainMenuMusic.play()
	$Animations/LeftMonkey.play("default")
	$Animations/RightMonkey.play("default")

"""
* Pre: Play is pressed
* Post: Takes you to the main portion of the game
* Return: None
"""
func _on_Play_pressed() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/BaseGame.tscn")

"""
* Pre: Options button is pressed
* Post: Opens up the options menu
* Return: None
"""
func _on_Options_pressed():
	var new_opt:Popup = options_scene.instance()
	$CanvasLayer.add_child(new_opt)
	new_opt.popup_centered()

"""
* Pre: Credits button is pressed
* Post: Opens up the credits popup-menu
* Return: None
"""
func _on_Credits_pressed() -> void:
	var new_credits:Popup = credits_scene.instance()
	$CanvasLayer.add_child(new_credits)
	new_credits.popup_centered()

"""
* Pre: Quit button is pressed
* Post: Exits you from the game
* Return: None
"""
func _on_Quit_pressed() -> void:
	get_tree().quit()

func _credits_focus(value:bool) -> void:
	if value:
		$CanvasLayer/CenterContainer/Buttons/Credits.grab_focus()
	else:
		$CanvasLayer/CenterContainer/Buttons/Credits.release_focus()
