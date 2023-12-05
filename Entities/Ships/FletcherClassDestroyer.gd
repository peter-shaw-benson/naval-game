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

var fletcher_turret_path = "res://art/Turrets/Light Gun 1/LightGunSprite.tres"

# this determines the placement of each individual turret. 
# while this seems excessive for a simple ship, if we want to add MG's or something later, 
# this will become much more complex (with multiple sprite paths, multiple offsets, etc).

var turret_list = [
	{"weapon": LightGun.new(), "offset": [0,30], "barrels": 1, 
	"sprite_path": fletcher_turret_path, "turn_weight":0.02},
	{"weapon": LightGun.new(), "offset": [0,20], "barrels": 1, 
	"sprite_path": fletcher_turret_path, "turn_weight":0.02},
	{"weapon": LightGun.new(), "offset": [0,10], "barrels": 1, 
	"sprite_path": fletcher_turret_path, "turn_weight":0.02},
	# these two are the forward guns
	{"weapon": LightGun.new(), "offset": [0,-10], "barrels": 1, 
	"sprite_path": fletcher_turret_path, "turn_weight":0.02},
	{"weapon": LightGun.new(), "offset": [0,-20], "barrels": 1, 
	"sprite_path": fletcher_turret_path, "turn_weight":0.02}
]

var ship_stats = {
	"speed": 42,
	"range": 1000,
	"turn_weight": 0.1,
	"hit_points": 12,
	"armor": 5.5,
	"hide": 20,
	"visibility": 30,
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
