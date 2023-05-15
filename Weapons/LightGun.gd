extends "res://Weapons/Weapon.gd"

var weapon_stats = {
	"max_range": 40,
	"fire_rate": 1,
	"damage": 1,
	"piercing": 6,
	"armor_damage": 0.2,
	"anti_air": 0.5,
	"base_accuracy": 0.25,
	"accuracy_gain": 0.03
}

func _init():
	
	self.init(weapon_stats["max_range"], \
	weapon_stats["fire_rate"], weapon_stats["damage"], weapon_stats["piercing"], \
	weapon_stats["armor_damage"], weapon_stats["anti_air"], \
	weapon_stats["base_accuracy"], weapon_stats["accuracy_gain"])
