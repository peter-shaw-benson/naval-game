extends "res://Weapons/Weapon.gd"

var weapon_stats = {
	"max_range": 10,
	"fire_rate": 1,
	"damage": 1,
	"piercing": 0,
	"armor_damage": 0,
	"anti_air": 5,
	"base_accuracy": 0.8,
	"accuracy_gain": 0
}

func _init():
	
	self.init(weapon_stats["max_range"], \
	weapon_stats["fire_rate"], weapon_stats["damage"], weapon_stats["piercing"], \
	weapon_stats["armor_damage"], weapon_stats["anti_air"], \
	weapon_stats["base_accuracy"], weapon_stats["accuracy_gain"])
