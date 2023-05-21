extends Popup

const SCROLL_SPEED = 5

"""
* Pre: Called to initialize credits popup
* Post: tells main menu to unfocus on the button
* Return: None
"""
func _ready() -> void:
	GlobalSignals.emit_signal("unselect_credits_button", false)

#Function that helps with scrolling with keyboard
#Credit for how to implement:
#https://www.reddit.com/r/godot/comments/10mfxj5/how_can_i_control_scrolling_from_richtextlabel/
func _process(_delta):
	if Input.is_action_pressed("ui_down"):
		$MarginContainer/CreditsText.get_v_scroll().value += SCROLL_SPEED
	elif Input.is_action_pressed("ui_up"):
		$MarginContainer/CreditsText.get_v_scroll().value -= SCROLL_SPEED

"""
* Pre: Popup is hidden
* Post: deletes the popup from memory
* Return: None
"""
func _on_CreditsPopup_popup_hide() -> void:
	GlobalSignals.emit_signal("unselect_credits_button", true)
	queue_free()
