class_name Battleship
extends Ship

var LightGun = preload("res://Weapons/LightGun.gd")
var MediumGun = preload("res://Weapons/MediumGun.gd")
var HeavyGun = preload("res://Weapons/HeavyGun.gd")

# List of Destroyer Names
var DestroyerNames = ["HMS Beverly",
"HMS Burwell",
"HMS Burnham",
"HMS Hamilton",
"HMS Lancaster",
"HMS Mansfield",
"HMS Clare",
"HMS Stanley",
"HMS Ramsey",
]

var ship_stats = {
	"speed": 25,
	"range": 1000,
	"turn_weight": 0.05,
	"hit_points": 30,
	"armor": 10,
	"hide": 20,
	"visibility": 25,
	"crew": 8,
	"class": "Battleship",
	"weapons": [LightGun.new(), MediumGun.new(), HeavyGun.new(), HeavyGun.new()]
}

func _init():
	
	self.init(ship_stats["speed"], ship_stats["range"], ship_stats["turn_weight"], \
	ship_stats["hit_points"], ship_stats["armor"], \
	ship_stats["hide"], ship_stats["visibility"], \
	ship_stats["crew"])
	
	self.set_class(ship_stats["class"])
	self.armament(ship_stats["weapons"])
	
	# choose name from list
	var name = DestroyerNames[randi() % DestroyerNames.size()]
	self.set_name(name)

func _ready():
	pass
