extends Node
class_name Weapon

var max_range: float
var fire_rate: int
var damage: float

var piercing: float
var armor_damage: float

var anti_air: float

var base_accuracy: float
# implement accuracy gain later
var accuracy_gain: float

var speed = 200

var weapon_data_path = "res://Weapons/weapon_stats.json"

var weapon_data: Dictionary
	
func read_json_file(file_path):
	# from the internets
	var file = File.new()
	file.open(file_path, File.READ)
	
	var content_as_text = file.get_as_text()

	print(content_as_text)
	
	#load_weapon_stats(content_as_text)
	
	# TESTING:
	#var test_data = "[0,1,2]"
	#test_data = '{"jello": "marshmallow"}'
	#test_data = '{"Torpedo": {"name": "torpedo","speed": 20},"LightGun": {"name": "lightgun""speed": 450,"max_range": 100,"fire_rate": 1,"damage": 0.5,"piercing": 2,"armor_damage": 0.2,"anti_air": 1,"base_accuracy": 0.3,"accuracy_gain": 0.03}}'
	
	var data_received = JSON.parse(content_as_text).result
		
	#print(data_received)
	
	return data_received

func init(weapon_name):
	
	print("reading weapons from file")
	weapon_data = read_json_file(weapon_data_path)[weapon_name]

func get_fire_rate():
	return self.weapon_data["fire_rate"]
	
func get_range():
	return self.weapon_data["max_range"]

func get_speed():
	return self.weapon_data["speed"]
	
func get_damage():
	return self.weapon_data["damage"]

func get_name():
	return self.weapon_data["name"]
