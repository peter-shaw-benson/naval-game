class_name Cruiser
extends Ship

var LightGun = preload("res://Weapons/LightGun.gd")
var MediumGun = preload("res://Weapons/MediumGun.gd")

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
	"speed": 30,
	"turn_weight": 0.08,
	"hit_points": 20,
	"armor": 7,
	"hide": 20,
	"visibility": 20,
	"crew": 6,
	"class": "Cruiser",
	"weapons": [LightGun.new(), MediumGun.new(), MediumGun.new()]
}

func _init():
	
	self.init(ship_stats["speed"], ship_stats["turn_weight"], \
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
