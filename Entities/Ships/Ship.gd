class_name Ship
extends "../Entity.gd"

# Navigation Variables
var ship_name: String

var module_hit_chances = {
	"engine": 0.02,
	"battery": 0.01,
	"rudder": 0.03,
	"armor": 0.05, 
	"hangar": 0.06
}

var damaged_rudder = false
var damaged_engine = false

func set_name(ship_name):
	self.ship_name = ship_name

func get_name(): return self.ship_name

func _to_string():
	var s = ""
	s += "\nSHIP CLASS " + self.entity_class + "\n"
	s += self.ship_name + "\n"
	
	# Add parent to string?

	return s
	
func subsystem_damage(accuracy_roll, total_accuracy, damage_result):
	 #special conditions:
	if accuracy_roll <= (module_hit_chances["battery"] * total_accuracy):
			#print("hit battery")
		damage_result *= 2
				
			# remove a weapon
		if weapons_list.size() > 0:
			weapons_list.remove(randi() % weapons_list.size())
			
		emit_signal("hit_subsystem", "battery")
				
		# decreases turn weight on rudder hit
	elif accuracy_roll <= (module_hit_chances["rudder"] * total_accuracy)\
	and not damaged_rudder:
			#print("hit rudder")
		damage_result *= 1.2
				
			# decrease turn speed
		self.turn_weight = self.turn_weight / 2
				
		damaged_rudder = true
		emit_signal("hit_subsystem", "rudder")
			
		# decreases speed on engine hit
	elif accuracy_roll <= (module_hit_chances["engine"] * total_accuracy)\
	and not damaged_engine:
			#print("hit engine")
		damage_result *= 1.5
				
			# decrease turn speed
		self.speed = self.speed * 0.9
				
		damaged_engine = true	
		emit_signal("hit_subsystem", "engine")
				
	elif accuracy_roll <= (module_hit_chances["armor"] * total_accuracy):
			#print("hit armor")
		damage_result *= 1.2
			
		self.armor *= 0.8
		emit_signal("hit_subsystem", "armor")
		
	return damage_result
	
func damage(weapon: Weapon, t_crossed, distance, enemy_stopped):
	var range_factor_damage = GameState.get_rangeFactor() + 1
	
	var hit_dict = calculate_hit(weapon, distance, enemy_stopped, true)
	
	if hit_dict["hit"]:
		#print("hit scored!")
		var damage_result = 0
		# No matter what, a weapon will somewhat damage the armor of a ship
		
		var armor_diff = weapon.piercing - armor
		
		# Armor Piercing calculation

		if armor_diff >= 0:
			damage_result = weapon.damage
		elif armor_diff < 0:
			damage_result = weapon.damage / GameState.get_armorReduction()
		
		damage_result = subsystem_damage(hit_dict["roll"], hit_dict["final"], damage_result)
		
		damage_result *= range_factor_damage 
		
		if t_crossed:
			if damage_result > 0:
				damage_result *= 2

		hit_points -= damage_result
