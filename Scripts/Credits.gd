extends Popup

"""
* Pre: Popup is hidden
* Post: deletes the popup from memory
* Return: None
"""
func _on_CreditsPopup_popup_hide() -> void:
	queue_free()
