class_name FletcherClassDestroyer
extends Ship

var LightGun = preload("res://Weapons/LightGun.gd")
var Torpedo = preload("res://Weapons/Torpedo.gd")

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

var turret_list = [
	{"weapon": LightGun.new(), "y_offset": 30, "barrels": 1},
	{"weapon": LightGun.new(), "y_offset": 20, "barrels": 1},
	{"weapon": LightGun.new(), "y_offset": 0, "barrels": 1},
	{"weapon": LightGun.new(), "y_offset": -10, "barrels": 1},
	{"weapon": LightGun.new(), "y_offset": -20, "barrels": 1},
]

var ship_stats = {
	"speed": 42,
	"range": 1000,
	"turn_weight": 0.1,
	"hit_points": 12,
	"armor": 5.5,
	"hide": 20,
	"visibility": 15,
	"crew": 5,
	"class": "Destroyer",
	"turrets": turret_list
}

func _init():
	
	self.init(ship_stats["speed"], ship_stats["range"], ship_stats["turn_weight"], \
	ship_stats["hit_points"], ship_stats["armor"], \
	ship_stats["hide"], ship_stats["visibility"], \
	ship_stats["crew"])
	
	self.set_class(ship_stats["class"])
	self.armament(ship_stats["turrets"])
	
	# choose name from list
	var name = DestroyerNames[randi() % DestroyerNames.size()]
	self.set_name(name)

func _ready():
	pass
