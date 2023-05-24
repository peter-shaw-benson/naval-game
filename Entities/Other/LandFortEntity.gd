class_name LandFort
extends Ship

var LightGun = preload("res://Weapons/LightGun.gd")
var MediumGun = preload("res://Weapons/MediumGun.gd")
var HeavyGun = preload("res://Weapons/HeavyGun.gd")

# List of Destroyer Names
var Names = [
	"Fort Stanley",
	"Fort Miles", 
	"Fort Clinch",
	"Red Fort"
]

var ship_stats = {
	"speed": 0,
	"range": 0,
	"turn_weight": 0,
	"hit_points": 80,
	"armor": 12,
	"hide": 20,
	"visibility": 15,
	"crew": 8,
	"class": "LandFort",
	"weapons": [LightGun.new(), LightGun.new(), HeavyGun.new(), HeavyGun.new()]
}

func _init():
	
	self.init(ship_stats["speed"], ship_stats["range"], \
	ship_stats["turn_weight"], \
	ship_stats["hit_points"], ship_stats["armor"], \
	ship_stats["hide"], ship_stats["visibility"], \
	ship_stats["crew"])
	
	self.set_class(ship_stats["class"])
	self.armament(ship_stats["weapons"])
	
	# choose name from list
	var name = Names[randi() % Names.size()]
	self.set_name(name)

func _ready():
	pass
