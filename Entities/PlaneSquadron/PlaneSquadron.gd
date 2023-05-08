extends Area2D
class_name PlaneSquadron

signal planes_recovered(plane_squad)

var plane_list = []

var target: Vector2
var airbase_origin: Vector2
var current_target: Vector2
var strike_force: bool

var faction = 0
var base_speed
var max_range = 300

func _ready():
	pass

func init(plane_list, initial_pos, target, faction, strike=false):
	self.plane_list = plane_list
	
	global_position = initial_pos
	
	target = target
	current_target = target
	airbase_origin = initial_pos
	strike_force = strike
	
	base_speed = get_base_speed()
	faction = faction
	
	if faction != GameState.get_playerFaction(): 
		self.hide()

	# Set animations
	if strike:
		get_node("AnimatedSprite").animation = "fighterDeselected"
	else:
		get_node("AnimatedSprite").animation = "scoutPlaneDeselected"
			
	get_node("AnimatedSprite").frame = faction
	get_node("AirbaseCollision").disabled = true
			
	rotation = global_position.angle_to_point(target) - PI/2

func get_base_speed():
	return 120

func get_strike():
	return strike_force

func get_faction():
	return faction

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
