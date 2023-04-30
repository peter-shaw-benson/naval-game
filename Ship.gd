extends Node
class_name Ship

var speed: int
var turn_rate: int

func _init(speed, turn_rate):
	self.speed = speed
	self.turn_rate = turn_rate
	
func get_speed():
	return self.speed

func get_turn_rate():
	return self.turn_rate
