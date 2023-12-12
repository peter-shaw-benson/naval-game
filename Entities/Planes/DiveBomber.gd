extends "res://Entities/Planes/Plane.gd"

var DiveBomb = preload("res://Weapons/PlaneWeapons/DiveBomb.gd")
var MG = preload("res://Weapons/MachineGun.gd")

var weapon_list = [DiveBomb.new(), MG.new()]

func _init():
	
	self.init("plane", "dive")
	
	self.armament(weapon_list)
