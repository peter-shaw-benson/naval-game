extends Node2D

signal right_click(placement)
signal left_click(placement)

func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			emit_signal("left_click", event.position)
			
			#print("Left button was clicked at ", event.position)
		elif event.pressed and event.button_index == 2:
			emit_signal("right_click", event.position)
			#print("Right button was clicked at ", event.position)
