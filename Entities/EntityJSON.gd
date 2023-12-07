extends Node
class_name EntityJSON

signal hit_subsystem(type)

# Navigation Variables
var speed: int
var max_speed: int

var max_range: int

var turn_weight: float
var max_turn_weight: float

var entity_class: String
var wind_resistance: float
# Combat Variables
var hide_range: int
var visibility_range: int
var crew: float

var hit_points: float
var max_health: float

var armor: float
var max_armor: float

# this is an array where each element is a dict.
# weapon, y_offset, barrels
var weapons_list: Array
var aircraft_list = []

# 
var entity_data_path = "res://config_files/entity_stats.json"
#var entity_data_path = "res://Weapons/weapon_stats.json"


var entity_data: Dictionary

func read_json_file(file_path):
	# from the internets
	var file = File.new()
	file.open(file_path, File.READ)
	
	var content_as_text = file.get_as_text()

	print(content_as_text)
	
	var data_received = JSON.parse(content_as_text).result
	
	print(data_received)
	
	return data_received

func init(entity_type, entity_name):
	
	print("reading entity data from file")
	entity_data = read_json_file(entity_data_path)[entity_type][entity_name]

	self.max_speed = entity_data["speed"]
	
	self.max_turn_weight = entity_data["turn_weight"]
	
	self.hit_points = entity_data["hit_points"]
	self.max_health = entity_data["hit_points"]
	
	self.armor = entity_data["armor"]
	self.max_armor = entity_data["armor"]
	
	self.crew = entity_data["crew"]
	self.wind_resistance = 0.9
	
	self.entity_class = entity_data["class"]

func get_wind_resist():
	return wind_resistance

func get_class():
	return entity_class

func set_name(ship_name):
	self.ship_name = ship_name

func armament(weapon_list):
	self.weapons_list = weapon_list
	
func get_speed():
	return self.entity_data["speed"]

func get_turn_weight():
	return self.entity_data["turn_weight"]

func get_visibility():
	return self.entity_data["visibility"]

func get_hiding():
	return self.entity_data["hide"]
#
#func weapons_to_string():
#	var string = ""
#
#	for weapon in weapons_list:
#		string += weapon.to_string()
#
#	return string

func get_health():
	return self.hit_points

func get_max_health():
	return self.entity_data["hit_points"]

func get_armor():
	return self.armor

func get_weapons():
	return self.weapons_list

func get_range():
	return self.entity_data["range"]
	
# Combat function
func damage(weapon: Weapon):
	
	self.hit_points -= weapon.get_damage()
#
#func _to_string():
#	var s = ""
#	s += "Speed: \t" + str(self.speed)
#	s += "Turn Weight: \t" + str(self.turn_weight)
#	s += "HP: \t" + str(self.hit_points)
#	s += "Armor: \t" + str(self.armor)
#	s += "Visibility Range: \t" + str(self.visibility_range)
#	s += "Crew: \t" + str(self.crew)
#
#	s += "\nWEAPONS\n"
#
#	s += self.weapons_to_string()

func repair():
	pass
