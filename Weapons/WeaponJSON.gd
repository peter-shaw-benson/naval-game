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
