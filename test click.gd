extends Area2D

func _input_event(viewport, event, shape_idx):
	if event.type == InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		print("Clicked")
