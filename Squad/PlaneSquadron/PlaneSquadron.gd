extends "res://Squad/CombatUnitsWrapper.gd"
class_name PlaneSquadron

signal planes_recovered(plane_squad)
signal plane_squad_lost(plane_squad)

var airbase_origin: Vector2
var strike_force: bool
var carrier_origin: Carrier
var reached_target = false

# CAP variables
var combat_air_patrol = false
var patrolling = false
var cap_resolution = 4

var weapon_list = []
var plane_list = []

var cap_timing = 5

func _ready():
	self.scale = Vector2(0.6, 0.6)
	
	if self.sprite_type == "torpBomber":
		self.scale = Vector2(0.5, 0.5)
	
	airbase_origin = global_position

	for u in self.get_units():
		plane_list.append(u)
	
	update_weapon_list()
	
	enable_spotting()
	
	get_node("HealthBar").set_max(get_total_health())
	update_healthbar()
	#get_node("ArmorBar").set_max(get_total_armor())
	self.deselect()
	
func set_animation(strike, type):
	strike_force = strike
	sprite_type = type
	
	print("plane sprite:")
	print(sprite_type)
	
	get_node("AnimatedSprite").animation = sprite_type + "_basic"
	
	get_node("AnimatedSprite").frame = faction
	get_node("AirbaseCollision").disabled = true

func set_target(target):
	current_target = target

	rotation = global_position.angle_to_point(target) - PI/2

func set_combat_air_patrol(is_cap):
	combat_air_patrol = is_cap
	
	if combat_air_patrol:
		get_node("CAPTimer").wait_time = cap_timing
		
		get_node("CAPTimer").start()
		print("started CAP")

func get_sprite_type():
	return self.sprite_type

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
	
func get_strike():
	return strike_force

func get_faction():
	return faction

func get_weapon_list():
			
	return self.weapon_list

func is_patrolling():
	return patrolling

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
	
	if global_position.distance_to(current_target) < 10\
	or global_position.distance_to(airbase_origin) >= max_range\
	and not patrolling:
		if not combat_air_patrol:
			current_target = airbase_origin
			rotation = global_position.angle_to_point(current_target) - PI/2
			reached_target = true
			
			get_node("AirbaseCollision").disabled = false
			
		else:
			get_node("CAPTimer").start()
			
			patrolling = true
	
	if patrolling:
		var patrol_center
		
		if carrier_origin:
			patrol_center = carrier_origin.global_position
		else:
			patrol_center = airbase_origin
			# get angle to airbase origin, normalize
		var angle_to_airbase = global_position.angle_to_point(patrol_center) + ((PI / 2) /  cap_resolution)
		var angle_vector = Vector2(
			cos(angle_to_airbase),
			sin(angle_to_airbase)
		).normalized()
			# multiply by max range
		current_target = angle_vector * max_range
			
		rotation = global_position.angle_to_point(patrol_center)
		#print("CAP timer time left:" + str(get_node("CAPTimer").time_left))
	
	get_node("HealthBar").value = lerp(get_node("HealthBar").value, get_total_health(), get_process_delta_time())
	#get_node("ArmorBar").value = lerp(get_node("ArmorBar").value, get_total_health(), get_process_delta_time())
	
	# go back to carrier
	if carrier_origin and reached_target:
		update_carrier_pos()
	
		rotation = global_position.angle_to_point(current_target)-+ PI/2

	calc_new_velocity()
	global_position = global_position.move_toward(get_movement_vector(), delta*(velocity_vector.length()))

func _on_PlaneSquad_area_entered(area):
	#print("plane hit base")
	if area.get_faction() == self.get_faction():
		if current_target.distance_to(area.global_position) < 5:
			
			emit_signal("planes_recovered", self)

func carrier_launch(carrier):
	carrier_origin = carrier

func update_carrier_pos():
	current_target = carrier_origin.global_position

func handle_right_click(placement):
	pass

func _on_CAPTimer_timeout():
	print("cap timer ended")
	
	current_target = airbase_origin
	
	patrolling = false
	combat_air_patrol = false
	
	rotation = global_position.angle_to_point(current_target) - PI/2
	reached_target = true
			
	get_node("AirbaseCollision").disabled = false
