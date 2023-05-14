extends "res://Entities/Entity.gd"

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

func set_crew(crew_in):
	self.crew = crew_in

func get_crew():
	return self.crew
	
func set_hit_points(hp_in):
	self.hit_points = hp_in

func get_hit_points():
	return self.hit_points
	
func set_armor(armor_in):
	self.armor = armor_in

func get_armor():
	return self.armor

func set_weapons_list(weapons_list_in):
	self.weapons_list = weapons_list_in

func get_weapons_list():
	return self.weapons_list
	
func weapons_to_string():
	var string = ""
	
	for weapon in weapons_list:
		string += weapon.to_string()
		
	return string

func _to_string():
	print("Speed: \t", self.speed)
	print("Turn Weight: \t", self.turn_weight)
	print("HP: \t", self.hit_points)
	print("Armor: \t", self.armor)
	print("Visibility Range: \t", self.visibility_range)
	print("Crew: \t", self.crew)
	
	print("\nWEAPONS\n")
	
	print(self.weapons_to_string())

	

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
