extends Node

"""
* Purpose: To let board class know if player has moved
* Used in: Player.gd
* Params: direction (String to say left,right,up, or down)
*		  is_dash (tells if dash move or not)
"""
# warning-ignore:unused_signal
signal player_moved(direction, is_dash)

"""
* Purpose: To let player know they can change position
* Used in: Board.gd
* Params: new_pos (Vector2), is_down (tells if going down or not)
"""
# warning-ignore:unused_signal
signal change_position(new_pos, is_down)

"""
* Purpose: To let main menu whether to select button or not
* Used in: Credits.gd
* Params: value (boolean, true if to select)
"""
# warning-ignore:unused_signal
signal unselect_credits_button(value)
