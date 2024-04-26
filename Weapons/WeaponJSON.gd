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

var weapon_data_path = "res://config_files/weapon_stats.json"

var weapon_data: Dictionary
	
func read_json_file(file_path):
	# from the internets
	var file = File.new()
	file.open(file_path, File.READ)
	
	var content_as_text = file.get_as_text()

	#print(content_as_text)
	
	var data_received = JSON.parse(content_as_text).result
	
	if data_received == null:
		print("ERROR IN JSON READING!!")
		
	#print(data_received)
	
	return data_received

func init(weapon_name):
	
	#print("reading weapons from file")
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
	
# lower accuracy is better (less spread)
func get_spread():
	return self.weapon_data["base_accuracy"]
	
func get_accuracy_gain():
	return self.weapon_data["accuracy_gain"]

func is_aa_gun():
	return self.weapon_data["aa_gun"]
