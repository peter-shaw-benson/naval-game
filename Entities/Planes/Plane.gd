class_name CombatPlane
extends "../Entity.gd"

var agility = 0.5
var max_range = 0

func _ready():
	pass
	
func set_agility(new_agility):
	self.agility = new_agility
	
func set_range(new_range):
	self.max_range = new_range
	
func get_range():
	return self.max_range

func damage(weapon: Weapon, t_crossed, distance):
	# Should be only based on anti air of the weapon
	
	var accuracy_roll = roller.randf()
	
	var range_factor_accuracy = distance * GameState.get_rangeFactor()
	var range_factor_damage = GameState.get_rangeFactor() + 1
	
	var hit = accuracy_roll < \
	((weapon.base_accuracy + range_factor_accuracy) * self.agility)
	var partial_hit = accuracy_roll < \
	((weapon.base_accuracy + range_factor_accuracy))
	
	var damage_result = weapon.anti_air * range_factor_damage
	
	if hit:
		hit_points -= damage_result
		
		if accuracy_roll <= (0.05 * weapon.base_accuracy):
			damage_result *= 2
	
	if partial_hit:
		hit_points -= (damage_result / 2)
