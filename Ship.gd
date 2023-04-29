extends Node
class_name Ship

var speed: int

func _init(speed_input):
	self.speed = speed_input
	
func get_speed():
	return self.speed
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
