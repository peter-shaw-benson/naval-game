class_name Destroyer
extends Ship

var LightGun = preload("res://Weapons/LightGun.gd")

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
	"speed": 40,
	"range": 1000,
	"turn_weight": 0.1,
	"hit_points": 10,
	"armor": 5,
	"hide": 20,
	"visibility": 15,
	"crew": 5,
	"class": "Destroyer",
	"weapons": [LightGun.new(), LightGun.new()]
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
