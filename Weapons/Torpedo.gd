extends "res://Weapons/Weapon.gd"

var weapon_stats = {
	"max_range": 100,
	"fire_rate": 10,
	"damage": 10,
	"piercing": 10,
	"armor_damage": 1,
	"anti_air": 0,
	"base_accuracy": 0.05,
	"accuracy_gain": 0.03
}

func _init():
	
	self.init(weapon_stats["max_range"], \
	weapon_stats["fire_rate"], weapon_stats["damage"], weapon_stats["piercing"], \
	weapon_stats["armor_damage"], weapon_stats["anti_air"], \
	weapon_stats["base_accuracy"], weapon_stats["accuracy_gain"])
