extends Node2D

const SquadFull = preload("res://Squad/SquadFull.gd")

signal right_click(placement)
signal left_click(placement)

var squad: SquadFull

#var course_draw_list := []		draw_line($Squadron.current_target, course_draw_list[0], Color.green, 1.5)

func _ready():
	set_process(true)
	
	squad = SquadFull.new()
	#var course_draw_list = []

func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			emit_signal("left_click", event.position)
			
			#print("Left button was clicked at ", event.position)
		elif event.pressed and event.button_index == 2:
			squad.handle_right_click(event.position)
			#print("Right button was clicked at ", event.position)

