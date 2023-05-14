extends "res://Squad/CombatUnitsWrapper.gd"
class_name PlaneSquadron

signal planes_recovered(plane_squad)

var airbase_origin: Vector2
var strike_force: bool

var max_range = 300

var weapon_list = []

func _ready():
	airbase_origin = global_position
	pass
			
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

# plane squadrons can't be selected (yet)
func select():
	pass
	
func deselect():
	pass

func get_strike():
	return strike_force

func get_faction():
	return faction

func get_weapon_list():
	weapon_list = []
	
	for u in units:
		for w in u.get_weapons():
			weapon_list.append(w)
	
func take_damage(weapon: Weapon, distance):
	# determine weapon's anti-air
	# aircraft are damaged when they spot an enemy fleet
	pass

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
