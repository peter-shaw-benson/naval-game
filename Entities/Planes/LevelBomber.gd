extends "res://Entities/Planes/Plane.gd"

var LevelBomb = preload("res://Weapons/PlaneWeapons/LevelBomb.gd")
var MG = preload("res://Weapons/PlaneWeapons/Machinegun.gd")

var plane_stats = {
	"speed": 50,
	"turn_weight": 0.15,
	"hit_points": 5,
	"armor": 1,
	"hide": 20,
	"visibility": 30,
	"crew": 3,
	"class": "LevelBomber",
	"weapons": [LevelBomb.new(), MG.new(), MG.new()]
}

func _init():
	
	self.init(plane_stats["speed"], plane_stats["turn_weight"], \
	plane_stats["hit_points"], plane_stats["armor"], \
	plane_stats["hide"], plane_stats["visibility"], \
	plane_stats["crew"])
	
	self.set_class(plane_stats["class"])
	self.armament(plane_stats["weapons"])
