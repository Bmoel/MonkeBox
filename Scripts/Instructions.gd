extends Popup

#SIGNALS
signal start_game()

#ONREADY VARS
onready var m1 = $InstructionTabs/Movement/MarginContainer/GridContainer/Monkey1
onready var m2 = $InstructionTabs/Movement/MarginContainer/GridContainer/Monkey2
onready var play_button = $"InstructionTabs/Conclusion/Play Button"
onready var myTabs = $InstructionTabs

#CONSTANTS
const DISTANCE = 50

#GLOBALS
var m1_places = [Vector2(370,200),Vector2(420,200),Vector2(420,150),Vector2(370,150)]
var m1_idx = 1
var m2_places = [Vector2(300,490),Vector2(400,490)]
var m2_idx = 1
var tmr = null
var previous_tab = 0

"""
* Pre: focuses on player inputs
* Post: helps cycle through tabs
* Return: None
"""
func _input(_event):
	if Input.is_action_just_pressed("ui_right",false):
		if myTabs.current_tab != 3:
			myTabs.current_tab += 1
	elif Input.is_action_just_pressed("ui_left",false):
		if myTabs.current_tab != 0:
			myTabs.current_tab -= 1

"""
* Pre: called when tab changes
* Post: perfroms actions for each tab
* Return: None
"""
func _on_InstructionTabs_tab_changed(tab):
	if tab == 1:
		m1.play("default")
		m1.position = m1_places[0]
		m2.position = m2_places[0]
		tmr = Timer.new()
		tmr.autostart = true
		tmr.wait_time = 1.5
		tmr.one_shot = false
		tmr.connect("timeout", self, "_move_monkey")
		add_child(tmr)
	elif tab == 3:
		play_button.grab_focus()
	if previous_tab == 1:
		m1.stop()
		m2.stop()
		tmr.disconnect("timeout", self, "_move_monkey")
		tmr.queue_free()
	previous_tab = tab

"""
* Pre: In tab 1
* Post: helps move monkeys/animations
* Return: None
"""
func _move_monkey() -> void:
	m2.play("default")
	m1.position = m1_places[m1_idx]
	m1_idx += 1
	if m1_idx == len(m1_places):
		m1_idx = 0
	m2.position = m2_places[m2_idx]
	m2_idx += 1
	if m2_idx == len(m2_places):
		m2_idx = 0

"""
* Pre: m2 animation finishes
* Post: stops it
* Return: None
"""
func _on_Monkey2_animation_finished():
	m2.stop()
	m2.frame = 0

"""
* Pre: play button pressed
* Post: starts the game
* Return: None
"""
func _on_Play_Button_pressed():
	emit_signal("start_game")
	queue_free()
