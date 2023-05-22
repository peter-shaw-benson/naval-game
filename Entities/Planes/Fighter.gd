extends "res://Entities/Planes/Plane.gd"

var MG = preload("res://Weapons/PlaneWeapons/Machinegun.gd")

var plane_stats = {
	"speed": 120,
	"range": 150,
	"turn_weight": 0.15,
	"hit_points": 1.5,
	"armor": 0,
	"hide": 20,
	"visibility": 10,
	"crew": 1,
	"class": "Fighter",
	"weapons": [MG.new()],
	"agility": 0.02,
	"launch_time": 1
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
