extends "res://Entities/Planes/Plane.gd"

var DiveBomb = preload("res://Weapons/PlaneWeapons/DiveBomb.gd")
var MG = preload("res://Weapons/PlaneWeapons/Machinegun.gd")

var plane_stats = {
	"speed": 100,
	"turn_weight": 0.15,
	"hit_points": 3,
	"armor": 0,
	"hide": 20,
	"visibility": 40,
	"crew": 2,
	"class": "DiveBomber",
	"weapons": [DiveBomb.new(), MG.new()]
}

func _init():
	
	self.init(plane_stats["speed"], plane_stats["turn_weight"], \
	plane_stats["hit_points"], plane_stats["armor"], \
	plane_stats["hide"], plane_stats["visibility"], \
	plane_stats["crew"])
	
	self.set_class(plane_stats["class"])
	self.armament(plane_stats["weapons"])
