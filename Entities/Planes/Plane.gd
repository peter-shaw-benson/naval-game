class_name CombatPlane
extends "../Entity.gd"

var agility = 0.5
var launch_time = 1

func _ready():
	pass
	
func set_agility(new_agility):
	self.agility = new_agility

func set_launch_time(new_time):
	self.launch_time = new_time

func get_launch_time():
	return self.launch_time


func damage(weapon: Weapon, t_crossed, distance, enemy_stopped):
	# Should be only based on anti air of the weapon
	var range_factor_damage = GameState.get_rangeFactor() + 1
	
	var hit = calculate_hit(weapon.base_accuracy * self.agility, distance, enemy_stopped)
	var partial_hit = calculate_hit(weapon.base_accuracy, distance, enemy_stopped)
	
	var damage_result = weapon.anti_air * range_factor_damage
	
	if hit:
		hit_points -= damage_result
	
	if partial_hit:
		hit_points -= (damage_result / 2)
