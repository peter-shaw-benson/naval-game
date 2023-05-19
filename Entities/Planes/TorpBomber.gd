extends "res://Entities/Planes/Plane.gd"

var AirTorpedo = preload("res://Weapons/PlaneWeapons/AirTorpedo.gd")
var MG = preload("res://Weapons/PlaneWeapons/Machinegun.gd")

var plane_stats = {
	"speed": 90,
	"range": 200,
	"turn_weight": 0.15,
	"hit_points": 10,
	"armor": 1,
	"hide": 20,
	"visibility": 10,
	"crew": 3,
	"class": "TorpedoBomber",
	"weapons": [AirTorpedo.new(), MG.new()],
	"launch_time": 2,
	"agility": 0.15
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
