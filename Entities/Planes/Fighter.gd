extends "res://Entities/Planes/Plane.gd"

var MG = preload("res://Weapons/MachineGun.gd")

var mg_turret_path = "res://art/Turrets/MG/MGTurret.tres"

var turret_list = [
	{"weapon": MG.new(), "offset": [0,0], "barrels": 4, 
	"sprite_path": mg_turret_path, "turn_weight":0, "firing_arc": [0, 0]}
]


func _init():
	
	self.init("plane", "fighter")
	
	self.armament(turret_list)
