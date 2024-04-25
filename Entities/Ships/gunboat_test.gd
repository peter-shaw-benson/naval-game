class_name Monitor
extends Ship

var LightGun = preload("res://Weapons/LightGun.gd")
var Torpedo = preload("res://Weapons/Torpedo.gd")
var MachineGun = preload("res://Weapons/MachineGun.gd")

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
var mg_turret_path = "res://art/Turrets/MG/MGTurret.tres"

# this determines the placement of each individual turret. 
# while this seems excessive for a simple ship, if we want to add MG's or something later, 
# this will become much more complex (with multiple sprite paths, multiple offsets, etc).

var turret_list = [
#	{"weapon": LightGun.new(), "offset": [0,30], "barrels": 1, 
#	"sprite_path": fletcher_turret_path, "turn_weight":0.02, "firing_arc": [-30, 210]},
	{"weapon": LightGun.new(), "offset": [0,-30], "barrels": 1, 
	"sprite_path": fletcher_turret_path, "turn_weight":0.02, "firing_arc": [150, 390]},
#	{"weapon": LightGun.new(), "offset": [20,0], "barrels": 1, 
#	"sprite_path": fletcher_turret_path, "turn_weight":0.02, "firing_arc": [270, 450]},
#	{"weapon": LightGun.new(), "offset": [-20,0], "barrels": 1, 
#	"sprite_path": fletcher_turret_path, "turn_weight":0.02, "firing_arc": [90, 270]}
]


func _init():
	
	self.init("ship", "fletcher_class_destroyer")
	
	self.armament(turret_list)
	
	# choose name from list
	var name = DestroyerNames[randi() % DestroyerNames.size()]
	self.set_name(name)

func _ready():
	pass
