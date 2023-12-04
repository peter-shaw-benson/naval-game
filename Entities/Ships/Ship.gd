class_name Ship
extends "../Entity.gd"

# Navigation Variables
var ship_name: String

var module_hit_chances = {
	"engine": 0.02,
	"battery": 0.01,
	"rudder": 0.03,
	"armor": 0.05, 
	"hangar": 0.06,
	"fire": 0.2
}

var subsystems_damaged = []

var damaged_rudder = false
var damaged_engine = false
var burning = false

var fuel_storage: float
var fuel_storage_max: float
var fuel_consumption: float

func set_name(ship_name):
	self.ship_name = ship_name
	
	
# Initialize fuel variables
func set_fuel(fuel_storage, consumption):
	self.fuel_storage = fuel_storage
	self.fuel_storage_max = fuel_storage
	self.fuel_consumption = consumption

func get_fuel():
	return fuel_storage

func get_max_fuel():
	return fuel_storage_max

func get_name(): return self.ship_name

func on_fire():
	return burning

func get_most_recent_damage():
	if subsystems_damaged.size() > 0:
		return subsystems_damaged[-1]
	else:
		return "healthy"

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
		
		subsystems_damaged.append("battery")
			
		emit_signal("hit_subsystem", "battery")
				
		# decreases turn weight on rudder hit
	elif accuracy_roll <= (module_hit_chances["rudder"] * total_accuracy)\
	and not damaged_rudder:
			#print("hit rudder")
		damage_result *= 1.2
				
			# decrease turn speed
		self.turn_weight = self.turn_weight / 2
		
		subsystems_damaged.append("rudder")
				
		damaged_rudder = true
		emit_signal("hit_subsystem", "rudder")
			
		# decreases speed on engine hit
	elif accuracy_roll <= (module_hit_chances["engine"] * total_accuracy)\
	and not damaged_engine:
			#print("hit engine")
		damage_result *= 1.5
				
			# decrease turn speed
		self.speed = self.speed * 0.7
		
		subsystems_damaged.append("engine")
				
		damaged_engine = true	
		emit_signal("hit_subsystem", "engine")
				
	elif accuracy_roll <= (module_hit_chances["armor"] * total_accuracy):
			#print("hit armor")
		damage_result *= 1.2
			
		self.armor *= 0.8
		
		subsystems_damaged.append("armor")
		
		emit_signal("hit_subsystem", "armor")
	
	# check for fire 
	var fire_roll = randf()
	if fire_roll < module_hit_chances["fire"] and not burning:
		burning = true
		#print("ship burning!")
	
	return damage_result
	
# commenting out for now
# func damage(weapon: Weapon):
#	var range_factor_damage = GameState.get_rangeFactor() + 1
#
#	var hit_dict = calculate_hit(weapon, distance, enemy_speed_mode, true)
#
#	if hit_dict["hit"]:
#		#print("hit scored!")
#		var damage_result = 0
#		# No matter what, a weapon will somewhat damage the armor of a ship
#
#		var armor_diff = weapon.piercing - armor
#
#		# Armor Piercing calculation
#
#		if armor_diff >= 0:
#			damage_result = weapon.damage
#		elif armor_diff < 0:
#			damage_result = weapon.damage / GameState.get_armorReduction()
#
#		damage_result = subsystem_damage(hit_dict["roll"], hit_dict["final"], damage_result)
#
#		damage_result *= range_factor_damage 
#
#		if t_crossed:
#			if damage_result > 0:
#				damage_result *= 2
#
#		hit_points -= damage_result

func repair():
	if hit_points < max_health:
		hit_points += 1
	
	if armor < max_armor:
		armor += 0.5
	
	if turn_weight < max_turn_weight:
		turn_weight += 0.5 * (max_turn_weight - turn_weight)
	
	if speed < max_speed:
		speed += 0.75 * (max_speed - speed)
	
	if burning: 
		burning = false
	
	if fuel_storage < fuel_storage_max:

		process_fuel(-10)

# Use fuel during movement. 
# set the modifier to a negative value to add fuel.
func process_fuel(consumption_modifier):
	
	fuel_storage -= consumption_modifier * fuel_consumption
	
	if fuel_storage > fuel_storage_max:
		fuel_storage = fuel_storage_max
