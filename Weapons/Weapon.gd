extends Node
class_name Weapon

var max_range: float
var fire_rate: int
var damage: float

var piercing: float
var armor_damage: float

var anti_air: float

var base_accuracy: float
# implement accuracy gain later
var accuracy_gain: float

var speed = 200

func init(speed, max_range, fire_rate, damage, piercing, armor_damage, anti_air, \
base_accuracy, accuracy_gain):
	self.speed = speed
	self.max_range = max_range
	self.fire_rate = fire_rate
	self.damage = damage * GameState.get_damageScaling()
	self.piercing = piercing
	self.armor_damage = armor_damage
	self.anti_air = anti_air
	self.base_accuracy = base_accuracy * GameState.get_accuracyScaling()
	self.accuracy_gain = accuracy_gain

func _to_string():
	print("Max Range: \t", self.max_range)
	print("Fire Rate: \t", self.fire_rate)
	print("Damage: \t", self.damage)
	print("Piercing: \t", self.piercing)
	print("Armor Damage: \t", self.armor_damage)
	print("Anti Air: \t", self.anti_air)
	print("Base Accuracy: \t", self.base_accuracy)
	print("Accuracy Gain: \t", self.accuracy_gain)

func get_fire_rate():
	return self.fire_rate
	
func get_range():
	return self.max_range

func get_speed():
	return self.speed
