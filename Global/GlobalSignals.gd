extends Node

"""
* Purpose: To let board class know if player has moved
* Used in: Player.gd
* Params: direction (String to say left,right,up, or down)
"""
# warning-ignore:unused_signal
signal player_moved(direction)

"""
* Purpose: To let player know they can change position
* Used in: Board.gd
* Params: new_pos (Vector2)
"""
# warning-ignore:unused_signal
signal change_position(new_pos)
