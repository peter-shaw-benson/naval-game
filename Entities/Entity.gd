extends Node

# Navigation Variables
var speed: int
var max_range: int
var turn_weight: float
var entity_class: String
var wind_resistance: float
# Combat Variables
var hide_range: int
var visibility_range: int
var crew: float
var hit_points: float
var armor: float

var weapons_list: Array
var aircraft_list = []

var roller = RandomNumberGenerator.new()

func init(speed, max_range, turn_weight, hit_points, armor, hide_range, visibility, crew):
	self.speed = speed
	self.max_range = max_range
	self.turn_weight = turn_weight
	
	self.hit_points = hit_points
	self.armor = armor
	self.hide_range = hide_range
	self.visibility_range = visibility
	self.crew = crew
	self.wind_resistance = 0.9

func set_class(entity_class):
	self.entity_class = entity_class
	
func get_wind_resist():
	return wind_resistance

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

func get_range():
	return self.max_range

# Combat function
func damage(weapon: Weapon, t_crossed, distance):
	pass

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
