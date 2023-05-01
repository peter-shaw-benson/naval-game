class_name Ship
extends Node

var speed: int
var turn_weight: float

func _init(speed, turn_weight):
	self.speed = speed
	self.turn_weight = turn_weight
	
func get_speed():
	return self.speed

func get_turn_weight():
	return self.turn_weight
