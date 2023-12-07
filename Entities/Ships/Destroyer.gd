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

var fletcher_turret_path = "res://art/Turrets/Light Gun 1/LightGunSprite.tres"

var turret_list = [
	{"weapon": LightGun.new(), "offset": [0,30], "barrels": 1, 
	"sprite_path": fletcher_turret_path, "turn_weight":0.02},
	{"weapon": LightGun.new(), "offset": [0,10], "barrels": 1, 
	"sprite_path": fletcher_turret_path, "turn_weight":0.02},
	# these two are the forward guns
	{"weapon": LightGun.new(), "offset": [0,-10], "barrels": 1, 
	"sprite_path": fletcher_turret_path, "turn_weight":0.02},
]

func _init():
	
	self.init("ship", "destroyer")
	
	self.armament(turret_list)
	
	# choose name from list
	var name = DestroyerNames[randi() % DestroyerNames.size()]
	self.set_name(name)

func _ready():
	pass
