class_name Ship
extends "../Entity.gd"

# Navigation Variables
var ship_name: String

func set_name(ship_name):
	self.ship_name = ship_name

func get_name(): return self.ship_name

func _to_string():
	var s = ""
	s += "\nSHIP CLASS " + self.entity_class + "\n"
	s += self.ship_name + "\n"
	
	# Add parent to string?

	return s

func damage(weapon: Weapon, t_crossed, distance):
	var accuracy_roll = roller.randf()
	
	var range_factor_accuracy = distance * GameState.get_rangeFactor()
	var range_factor_damage = GameState.get_rangeFactor() + 1
	
	var hit = accuracy_roll < (weapon.base_accuracy + range_factor_accuracy)
	
	if hit:
		#print("hit scored!")
		var damage_result = 0
		# No matter what, a weapon will somewhat damage the armor of a ship
		armor -= weapon.armor_damage
		
		var armor_diff = weapon.piercing - armor
		
		# Armor Piercing calculation
		if armor_diff >= weapon.damage:
			damage_result = weapon.damage
		elif armor_diff < weapon.damage:
			damage_result = armor_diff
		elif armor_diff >= 0:
			damage_result = 0
		
		# on a "20", double damage!
		if accuracy_roll <= (0.05 * weapon.base_accuracy):
			if damage_result > 0:
				damage_result *= 2
				
				# also should damage crew here
			else:
				damage_result = weapon.damage / 4
		
		damage_result *= range_factor_damage
		
		if t_crossed:
			if damage_result > 0:
				damage_result *= 2

		hit_points -= damage_result
