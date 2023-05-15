extends "res://Squad/CombatUnitsWrapper.gd"
class_name PlaneSquadron

signal planes_recovered(plane_squad)
signal plane_squad_lost(plane_squad)

var airbase_origin: Vector2
var strike_force: bool

var max_range = 300

var weapon_list = []
var plane_list = []

func _ready():
	self.scale = Vector2(0.6, 0.6)
	
	airbase_origin = global_position

	for u in self.get_units():
		plane_list.append(u)
	
	update_weapon_list()
	
func set_strike(strike):
	strike_force = strike
	
	# Set animations
	if strike:
		get_node("AnimatedSprite").animation = "fighterDeselected"
	else:
		get_node("AnimatedSprite").animation = "scoutPlaneDeselected"
			
	get_node("AnimatedSprite").frame = faction
	get_node("AirbaseCollision").disabled = true

func set_target(target):
	current_target = target

	rotation = global_position.angle_to_point(target) - PI/2

func get_min_range():
	
	if len(units) == 0:
		return 0
	else:
		var min_range = units[0].get_range()
		
		for unit in units:
			if unit.get_range() < min_range:
				min_range = unit.get_range()
		
		return min_range
		
func update_weapon_list():
	weapon_list = []
	
	for p in plane_list:
		for w in p.get_weapons():
			weapon_list.append(w)

# plane squadrons can't be selected (yet)
func select():
	pass
	
func deselect():
	pass

func update_armorbar():
	pass
	
func update_healthbar():
	pass

func get_strike():
	return strike_force

func get_faction():
	return faction

func get_weapon_list():
			
	return self.weapon_list

func take_damage(weapon: Weapon, distance):
	# determine weapon's anti-air
	# aircraft are damaged when they spot an enemy fleet
	if len(units) <= 0:
		emit_signal("squad_lost", self)
	else:
		# Damage Random Ship
		var damage_index = randi() % units.size()
		var damaged_plane = units[damage_index]
		
		# setting this to false until we fix t crossing
		damaged_plane.damage(weapon, false, distance)
		
		if damaged_plane.get_health() <= 0:
			units.remove(damage_index)
			
			# update weapon list
			self.weapon_list = update_weapon_list()
			
			if len(units) <= 0:
				emit_signal("plane_squad_lost", self)
				print("plane squad shot down")
				
	emit_signal("update_squad_info", get_squad_info())

func _process(delta):
	if global_position.distance_to(current_target) < 10:
		current_target = airbase_origin
		rotation = global_position.angle_to_point(current_target) - PI/2
		
		get_node("AirbaseCollision").disabled = false
		
	global_position = global_position.move_toward(current_target, delta * base_speed)

func _on_PlaneSquad_area_entered(area):
	#print("plane hit base")
	
	if airbase_origin.distance_to(area.global_position) < 5:
		
		emit_signal("planes_recovered", self)

