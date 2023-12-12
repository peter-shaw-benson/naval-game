extends "res://Entities/Planes/Plane.gd"

var LevelBomb = preload("res://Weapons/PlaneWeapons/LevelBomb.gd")
var MG = preload("res://Weapons/MachineGun.gd")

var plane_stats = {
	"speed": 50,
	"range": 500,
	"turn_weight": 0.15,
	"hit_points": 20,
	"armor": 1,
	"hide": 20,
	"visibility": 30,
	"crew": 3,
	"class": "LevelBomber",
	"weapons": [LevelBomb.new(), MG.new(), MG.new()],
	"agility": 0.4,
	"launch_time": 5
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
	
