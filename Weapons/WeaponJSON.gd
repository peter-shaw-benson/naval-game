extends Node
class_name WeaponJSON

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

func read_file(filename):
	var f = File.new()
	
	var filedata = ""
	
	f.open(filename, File.READ)
	
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		filedata += line + "\n"
		print(line)

	f.close()
	return filedata
	
func read_json_file(file_path):
	# from the internets
	var file = File.new()
	file.open(file_path, File.READ)
	
	var content_as_text = file.get_as_text()
	#print(content_as_text)
	
	var data_received = JSON.parse(content_as_text).result
	
	print(data_received)
	
	return data_received
	
	# convert to JSON
func load_weapon_stats(JSONdata):
	
	var json = JSON.new()
	var error = json.parse(JSONdata)
	
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			print(data_received) # Prints array
		else:
			print("Unexpected data")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", JSONdata, " at line ", json.get_error_line())

func init(weapon_name):
	
	print("reading weapons from file")
	weapon_data = read_json_file(weapon_data_path)
	
	print(weapon_data)
	
	self.speed = speed
	self.max_range = max_range
	self.fire_rate = fire_rate
	self.damage = damage * GameState.get_damageScaling()
	self.piercing = piercing
	self.armor_damage = armor_damage
	self.anti_air = anti_air
	self.base_accuracy = base_accuracy * GameState.get_accuracyScaling()
	self.accuracy_gain = accuracy_gain

func _to_string():
	print("Max Range: \t", self.max_range)
	print("Fire Rate: \t", self.fire_rate)
	print("Damage: \t", self.damage)
	print("Piercing: \t", self.piercing)
	print("Armor Damage: \t", self.armor_damage)
	print("Anti Air: \t", self.anti_air)
	print("Base Accuracy: \t", self.base_accuracy)
	print("Accuracy Gain: \t", self.accuracy_gain)

func get_fire_rate():
	return self.fire_rate
	
func get_range():
	return self.max_range

func get_speed():
	return self.speed
	
func get_damage():
	return self.damage
