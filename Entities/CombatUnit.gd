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

	
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
