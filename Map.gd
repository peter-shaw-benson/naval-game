extends Node2D

signal right_click(placement)
signal left_click(placement)

#var course_draw_list := []

var course_draw_list = []

func _ready():
	set_process(true)
	
	#var course_draw_list = []

func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			emit_signal("left_click", event.position)
			
			#print("Left button was clicked at ", event.position)
		elif event.pressed and event.button_index == 2:
			emit_signal("right_click", event.position)
			#print("Right button was clicked at ", event.position)


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
