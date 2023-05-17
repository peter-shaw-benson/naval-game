class_name CarrierEntity
extends Ship

var LightGun = preload("res://Weapons/LightGun.gd")

# List of Destroyer Names
var CarrierNames = ["HMS Glorious",
"HMS Hermes",
"HMS Ark Royal",
"USS Enterprise",
"USS Lexington"
]

var ship_stats = {
	"speed": 15,
	"range": 1000,
	"turn_weight": 0.06,
	"hit_points": 20,
	"armor": 7,
	"hide": 10,
	"visibility": 10,
	"crew": 10,
	"class": "Carrier",
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
	var name = CarrierNames[randi() % CarrierNames.size()]
	self.set_name(name)

func _ready():
	pass
