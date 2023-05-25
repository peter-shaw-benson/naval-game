extends "res://Entities/Planes/Plane.gd"

var DiveBomb = preload("res://Weapons/PlaneWeapons/DiveBomb.gd")
var MG = preload("res://Weapons/PlaneWeapons/Machinegun.gd")

var plane_stats = {
	"speed": 100,
	"range": 200,
	"turn_weight": 0.15,
	"hit_points": 8,
	"armor": 0,
	"hide": 20,
	"visibility": 15,
	"crew": 2,
	"class": "DiveBomber",
	"weapons": [DiveBomb.new(), MG.new()],
	"agility": 0.3,
	"launch_time": 1.5
}

func _init():
	
	self.init(plane_stats["speed"], plane_stats["range"], plane_stats["turn_weight"], \
	plane_stats["hit_points"], plane_stats["armor"], \
	plane_stats["hide"], plane_stats["visibility"], \
	plane_stats["crew"])
	
	self.set_class(plane_stats["class"])
	self.armament(plane_stats["weapons"])
	self.set_agility(plane_stats["agility"])
	self.set_launch_time(plane_stats["launch_time"])
