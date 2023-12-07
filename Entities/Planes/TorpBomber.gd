extends "res://Entities/Planes/Plane.gd"

var AirTorpedo = preload("res://Weapons/PlaneWeapons/AirTorpedo.gd")
var MG = preload("res://Weapons/PlaneWeapons/Machinegun.gd")

var weapon_list = [AirTorpedo.new(), MG.new()]

func _init():
	
	self.init("plane", "torp_bomber")
	
	self.armament(weapon_list)
