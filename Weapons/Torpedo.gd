extends "res://Weapons/WeaponJSON.gd"

var weapon_stats = {
	"name": "Torpedo",
	"speed": 20,
	"max_range": 500,
	"fire_rate": 10,
	"damage": 10,
	"piercing": 12,
	"armor_damage": 1,
	"anti_air": 0,
	"base_accuracy": 0.5,
	"accuracy_gain": 0.03
}

## TODO: make this a JSON basically

func _init():
	
	self.init("Torpedo")
	
#	self.init(weapon_stats["speed"], weapon_stats["max_range"], \
#	weapon_stats["fire_rate"], weapon_stats["damage"], weapon_stats["piercing"], \
#	weapon_stats["armor_damage"], weapon_stats["anti_air"], \
#	weapon_stats["base_accuracy"], weapon_stats["accuracy_gain"])
