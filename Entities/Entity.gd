extends Node

# Navigation Variables
var speed: int
var turn_weight: float
var entity_class: String
# Combat Variables

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

func _to_string():
	print("Speed: \t", self.speed)
	print("Turn Weight: \t", self.turn_weight)
	print("HP: \t", self.hit_points)
	print("Armor: \t", self.armor)
	print("Visibility Range: \t", self.visibility_range)
	print("Crew: \t", self.crew)
	
	print("\nWEAPONS\n")
	
	print(self.weapons_to_string())
