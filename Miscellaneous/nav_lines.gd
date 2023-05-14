extends Node2D


var course_draw_list = []

func _draw():
	
	draw_line($Squadron.global_position, $Squadron.current_target, Color.green, 1.5)
	
	if len(course_draw_list) >= 1:
		draw_line($Squadron.current_target, course_draw_list[0], Color.green, 1.5)
		
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
