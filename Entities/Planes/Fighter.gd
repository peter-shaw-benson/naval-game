extends "res://Entities/Planes/Plane.gd"

var MG = preload("res://Weapons/MachineGun.gd")

var weapon_list = [MG.new()]

func _init():
	
	self.init("plane", "fighter")
	
	self.armament(weapon_list)
