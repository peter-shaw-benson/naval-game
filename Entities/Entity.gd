extends Node

# Navigation Variables
var speed: int
var turn_weight: float
var entity_class: String
# Combat Variables
var hide_range: int
var visibility_range: int
var crew: float
var hit_points: float
var armor: float

var weapons_list: Array
var aircraft_list = []

var roller = RandomNumberGenerator.new()

func init(speed, turn_weight, hit_points, armor, hide_range, visibility, crew):
	self.speed = speed
	self.turn_weight = turn_weight
	
	self.hit_points = hit_points
	self.armor = armor
	self.hide_range = hide_range
	self.visibility_range = visibility
	self.crew = crew

func set_class(entity_class):
	self.entity_class = entity_class

func get_class():
	return entity_class

func set_name(ship_name):
	self.ship_name = ship_name

func armament(weapon_list):
	self.weapons_list = weapon_list
	
func get_speed():
	return self.speed

func get_turn_weight():
	return self.turn_weight

func get_visibility():
	return self.visibility_range

func get_hiding():
	return self.hide_range
	
func weapons_to_string():
	var string = ""
	
	for weapon in weapons_list:
		string += weapon.to_string()
		
	return string

func get_health():
	return self.hit_points

func get_armor():
	return self.armor

func get_weapons():
	return self.weapons_list


# Combat function
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

func _to_string():
	var s = ""
	s += "Speed: \t" + str(self.speed)
	s += "Turn Weight: \t" + str(self.turn_weight)
	s += "HP: \t" + str(self.hit_points)
	s += "Armor: \t" + str(self.armor)
	s += "Visibility Range: \t" + str(self.visibility_range)
	s += "Crew: \t" + str(self.crew)
	
	s += "\nWEAPONS\n"
	
	s += self.weapons_to_string()
