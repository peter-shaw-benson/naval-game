extends "res://Weapons/Weapon.gd"

var weapon_stats = {
	"speed": 1,
	"max_range": 10,
	"fire_rate": 1,
	"damage": 0.2,
	"piercing": 20,
	"armor_damage": 0.2,
	"anti_air": 0,
	"base_accuracy": 10,
	"accuracy_gain": 0.03
}

func _init():
	
	self.init(weapon_stats["speed"], weapon_stats["max_range"], \
	weapon_stats["fire_rate"], weapon_stats["damage"], weapon_stats["piercing"], \
	weapon_stats["armor_damage"], weapon_stats["anti_air"], \
	weapon_stats["base_accuracy"], weapon_stats["accuracy_gain"])
