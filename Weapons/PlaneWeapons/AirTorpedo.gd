extends "res://Weapons/Weapon.gd"

var weapon_stats = {
	"speed": 20,
	"max_range": 20,
	"fire_rate": 10,
	"damage": 8,
	"piercing": 12,
	"armor_damage": 4,
	"anti_air": 0,
	"base_accuracy": 0.05,
	"accuracy_gain": 0
}

func _init():
	
	self.init(weapon_stats["speed"], weapon_stats["max_range"], \
	weapon_stats["fire_rate"], weapon_stats["damage"], weapon_stats["piercing"], \
	weapon_stats["armor_damage"], weapon_stats["anti_air"], \
	weapon_stats["base_accuracy"], weapon_stats["accuracy_gain"])
