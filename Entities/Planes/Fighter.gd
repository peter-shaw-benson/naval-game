extends "res://Entities/Planes/Plane.gd"

var MG = preload("res://Weapons/PlaneWeapons/Machinegun.gd")

var weapon_list = [MG.new()]

func _init():
	
	self.init("plane", "fighter")
	
	self.armament(weapon_list)
