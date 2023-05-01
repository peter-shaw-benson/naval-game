class_name SquadFull
extends Node2D

const Squadron = preload("Squadron.gd")
const Destroyer = preload("res://Ships/Destroyer.gd")
#const Utils = preload("res://Utility.gd")

var course_draw_list = []
var squad: Squadron

func _ready():
	squad = Squadron.new()
	var ship_list = [Destroyer.new()]
	squad.init(ship_list, Vector2(200, 200))
	
	print(squad.get_min_speed())
	
	squad.connect("new_course_change", self, "_on_Squadron_new_course_change")
	squad.connect("reached_target", self, "_on_Squadron_reached_targe")

func _draw():
	draw_line(squad.global_position, squad.current_target, Color.green, 1.5)
	
	if len(course_draw_list) >= 1:
		draw_line(squad.current_target, course_draw_list[0], Color.green, 1.5)
		
		if len(course_draw_list) >= 2:
			for i in range(1,len(course_draw_list)):
				draw_line(course_draw_list[i-1], course_draw_list[i], Color.green, 1.5)
				
func _process(_delta):
	update()

func _on_Squadron_new_course_change(current_target, placement):
	#print(course_draw_list)
	course_draw_list.append(Vector2(placement))

func _on_Squadron_reached_target():
	course_draw_list.remove(0)

func handle_right_click(placement):
	squad.handle_right_click(placement)
