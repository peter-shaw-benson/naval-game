extends "res://Weapons/Weapon.gd"

var weapon_stats = {
	"speed": 450,
	"max_range": 100,
	"fire_rate": 1,
	"damage": 0.5,
	"piercing": 2,
	"armor_damage": 0.2,
	"anti_air": 1,
	"base_accuracy": 0.3,
	"accuracy_gain": 0.03
}

func _init():
	
	#self.init("LightGun")
	
	self.init(weapon_stats["speed"], weapon_stats["max_range"], \
	weapon_stats["fire_rate"], weapon_stats["damage"], weapon_stats["piercing"], \
	weapon_stats["armor_damage"], weapon_stats["anti_air"], \
	weapon_stats["base_accuracy"], weapon_stats["accuracy_gain"])
