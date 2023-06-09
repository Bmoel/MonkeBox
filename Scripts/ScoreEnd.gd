extends Popup

#ONREADY VARS
onready var ScoreObj = $FinalScore

"""
* Pre: Called when Popup in instanced
* Post: grabs focus of button
* Return: None
"""
func _ready() -> void:
	if OS.get_name() == "Web":
		$CanvasLayer/CenterContainer/Buttons/Quit.disconnect("pressed", self, "_on_Quit_pressed")
	$CenterContainer/Buttons/MainMenu.grab_focus()

"""
* Pre: Popup is hidden
* Post: deletes the popup from memory
* Return: None
"""
func set_score(final_score:int) -> void:
	var num_text = str(final_score)
	ScoreObj.text = "Final Score: " + num_text
	var BASE = 200
	var offset = (len(num_text) - 2) * 15
	ScoreObj.rect_position.x = BASE - offset
	ScoreObj.rect_position.y = 160

"""
* Pre: Button is pressed
* Post: Change scene to Main Menu
* Return: None
"""
func _on_MainMenu_pressed() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/MainMenu.tscn")

"""
* Pre: Button is pressed
* Post: Replay the game
* Return: None
"""
func _on_PlayAgain_pressed() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/BaseGame.tscn")

"""
* Pre: Button is pressed
* Post: Quit the game
* Return: None
"""
func _on_Quit_pressed() -> void:
	get_tree().quit()

"""
* Pre: Button is pressed
* Post: Toggle whether instructions are played again or not
* Return: None
"""
func _on_CheckButton_toggled(button_pressed):
	GlobalSignals.PlayInstructions = button_pressed
	$CenterContainer/Buttons/PlayAgain.grab_focus()
