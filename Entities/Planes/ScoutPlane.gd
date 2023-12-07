extends "res://Entities/Planes/Plane.gd"

var plane_stats = {
	"speed": 80,
	"range": 600,
	"turn_weight": 0.15,
	"hit_points": 40,
	"armor": 0,
	"hide": 20,
	"visibility": 25,
	"crew": 2,
	"class": "ScoutPlane",
	"weapons": [],
	"agility": 0.3,
	"launch_time": 3,
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
