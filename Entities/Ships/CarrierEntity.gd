class_name CarrierEntity
extends Ship

var LightGun = preload("res://Weapons/LightGun.gd")

# List of Destroyer Names
var CarrierNames = ["HMS Glorious",
"HMS Hermes",
"HMS Ark Royal",
"USS Enterprise",
"USS Lexington"
]

var hangar_hit_chance = 0.05
var plane_numbers: Dictionary

var fletcher_turret_path = "res://art/Turrets/Light Gun 1/LightGunSprite.tres"

# this determines the placement of each individual turret. 
# while this seems excessive for a simple ship, if we want to add MG's or something later, 
# this will become much more complex (with multiple sprite paths, multiple offsets, etc).

#var turret_list = [
#	{"weapon": LightGun.new(), "offset": [10,0], "barrels": 1, 
#	"sprite_path": fletcher_turret_path, "turn_weight":0.02},
#	{"weapon": LightGun.new(), "offset": [-10,0], "barrels": 1, 
#	"sprite_path": fletcher_turret_path, "turn_weight":0.02},
#]

var turret_list = []


func _init():
	
	self.init("ship", "carrier")
	
	self.armament(turret_list)
	
	
	module_hit_chances["hangar"] = hangar_hit_chance
	
	# choose name from list
	var name = CarrierNames[randi() % CarrierNames.size()]
	self.set_name(name)

func _ready():
	pass

func set_planes():
	self.plane_numbers = self.entity_data["planes"]

func get_planes():
	return self.entity_data["planes"]

func subsystem_damage(accuracy_roll, total_accuracy, damage_result):
	 #special conditions:
	if accuracy_roll <= (module_hit_chances["battery"] * total_accuracy):
			#print("hit battery")
		damage_result *= 2
				
			# remove a weapon
		weapons_list.remove(randi() % weapons_list.size())
			
		emit_signal("hit_subsystem", "battery")
				
		# decreases turn weight on rudder hit
	elif accuracy_roll <= (module_hit_chances["rudder"] * total_accuracy)\
	and not damaged_rudder:
			#print("hit rudder")
		damage_result *= 1.2
				
			# decrease turn speed
		self.turn_weight = self.turn_weight / 2
				
		damaged_rudder = true
		emit_signal("hit_subsystem", "rudder")
			
		# decreases speed on engine hit
	elif accuracy_roll <= (module_hit_chances["engine"] * total_accuracy)\
	and not damaged_engine:
			#print("hit engine")
		damage_result *= 1.5
				
			# decrease turn speed
		self.speed = self.speed * 0.9
				
		damaged_engine = true	
		emit_signal("hit_subsystem", "engine")
	
	elif accuracy_roll <= (module_hit_chances["hangar"] * total_accuracy):
		damage_result *= 1.5
				
			# decrease turn speed
		self.max_planes = self.max_planes * 0.7
				
		emit_signal("hit_subsystem", "hangar")
				
	elif accuracy_roll <= (module_hit_chances["armor"] * total_accuracy):
			#print("hit armor")
		damage_result *= 1.2
			
		self.armor *= 0.8
		emit_signal("hit_subsystem", "armor")
		
	return damage_result
