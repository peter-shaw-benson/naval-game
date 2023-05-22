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

var ship_stats = {
	"speed": 15,
	"range": 1000,
	"turn_weight": 0.06,
	"hit_points": 20,
	"armor": 7,
	"hide": 10,
	"visibility": 10,
	"crew": 10,
	"class": "Carrier",
	"weapons": [LightGun.new(), LightGun.new()],
	"max_planes": 12
}

var hangar_hit_chance = 0.05
var max_planes: int

func _init():
	
	self.init(ship_stats["speed"], ship_stats["range"], ship_stats["turn_weight"], \
	ship_stats["hit_points"], ship_stats["armor"], \
	ship_stats["hide"], ship_stats["visibility"], \
	ship_stats["crew"])
	
	self.set_class(ship_stats["class"])
	self.armament(ship_stats["weapons"])
	self.set_max_planes(ship_stats["max_planes"])
	
	module_hit_chances["hangar"] = hangar_hit_chance
	
	# choose name from list
	var name = CarrierNames[randi() % CarrierNames.size()]
	self.set_name(name)

func _ready():
	pass
	
func set_max_planes(new_max):
	max_planes = new_max
	
func get_max_planes():
	return max_planes

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
