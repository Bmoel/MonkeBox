#Credit:
#	Help from https://godotengine.org/qa/53966/kinematic-bounce-back-when-hits-another-kinematic-static-body

extends KinematicBody2D

#CONSTANTS
const speed = 1100

#GLOBALS
var direction = Vector2.ZERO

"""
* Pre: Called when KinematicBody is initialized
* Post: Sets semi-random position and direction
* Return: None
"""
func _ready() -> void:
	randomize()
	var x = 10
	if rand_range(0,1) > 0.5:
		x *= -1
	var y = 10
	if rand_range(0,1) > 0.5:
		y *= -1
	direction = Vector2(x,y)
	var x_pos = rand_range(0.2,0.8)
	var y_pos = rand_range(0.2,0.8)
	position = Vector2(int(x_pos * 1280), int(y_pos * 720))

"""
* Pre: Called for every frame
* Post: Changes position and handles collision
* Return: None
"""
func _physics_process(delta) -> void:
	var velocity = speed * delta * direction
	# warning-ignore:return_value_discarded
	move_and_slide(velocity)
	if get_slide_count() > 0:
		var collision = get_slide_collision(0)
		if collision != null:
			direction = direction.bounce(collision.normal)
