extends "res://Entities/Planes/Plane.gd"

var weapon_list = []

func _init():
	
	self.init("plane", "scout")
	
	self.armament(weapon_list)
