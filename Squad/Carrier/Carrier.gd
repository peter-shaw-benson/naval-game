extends Airbase
class_name Carrier

var DiveBomber = preload("res://Entities/Planes/DiveBomber.gd")
var TorpBomber = preload("res://Entities/Planes/TorpBomber.gd")

var CarrierEntity = preload("res://Entities/Ships/CarrierEntity.gd")

# Ship Signals
signal new_course_change(current_target, placement)
signal reached_target()
signal squadron_lost(this_squad, enemy_squadron)
signal ship_lost(ship)
signal hit(squad)

var carrier_default_planes = [DiveBomber.new(), TorpBomber.new()]

var t_crossed = false
var target_array = []

var weapon_dict = {}
var stopped = false
var patrolling = false
var current_shot_count = 0 
var current_enemy_squadron: CombatUnitsWrapper

var plane_list


func init(unit_array, initial_position, faction, type):
	plane_list = carrier_default_planes
	units = [CarrierEntity.new()]
	
	type = type
	
	organize_aircraft(plane_list)
	
	#print(ships[0].speed)
	self.faction = faction
	#print("faction ", self.faction)
	
	# for some reason, we need to use deselect() 
	# just don't change it 
	self.deselect()
	
	base_speed = get_min_speed()
	turn_weight = get_min_turn_weight()
	visibility = get_visibility()
	hiding = get_hiding()
	self.wind_resist = get_squad_wind_resist()
	
	# Set up Visibility Collider and Hiding Collider
	var visibility_scale = visibility * 5
	#var hiding_scale = hiding * 10
	
	detector = detector_scene.instance()
	detector.init(visibility_scale)
	
	add_child(detector)
	
	detector.connect("entered_spotting_area", self, "on_detection_entered")
	detector.connect("left_spotting_area", self, "on_detection_left")
	
	self.initial_pos = initial_position
	self.current_speed = get_min_speed()
	self.velocity_vector = Vector2(0, 0)
	
	self.position = self.initial_pos
	
	# stopped, half, full ahead, flank
	var speed_array = [0, speed / 2, speed, int(speed * 1.2)]
	
	self.rotation = self.initial_rot
	turn_speed = int(self.base_speed / 2)
	
	self.applied_wind = Vector2(0, 0)
	# Set max of health bar and Armor Bar
	
	#print("squad created")


# Called when the node enters the scene tree for the first time.
func _ready():
	
	get_node("ShotTimer").wait_time = GameState.get_combatPace()
	self.weapon_dict = construct_weapon_dict()
	#print(weapon_dict)
	
	screen_size = get_viewport_rect().size
	
	get_node("HealthBar").set_max(get_total_health())
	get_node("ArmorBar").set_max(get_total_armor())
	
	self.update_healthbar()
	self.update_armorbar()
	
	# Make sure it doesn't crash until we're done placing
	get_node("IslandCollision").disabled = true

func get_min_speed():
	
	if len(units) == 0:
		return 0
	else:
		var min_speed = units[0].get_speed()
		
		for unit in units:
			if unit.get_speed() < min_speed:
				min_speed = unit.get_speed()
		
		return min_speed

func get_min_turn_weight():
	
	if len(units) == 0:
		return 0
	else:
		var min_turn_weight = units[0].get_turn_weight()
		
		for unit in units:
			if unit.get_turn_weight() < min_turn_weight:
				min_turn_weight = unit.get_turn_weight()
		
		return min_turn_weight

func get_visibility():
	if len(units) == 0:
		return 0
	else:
		var vis = units[0].get_visibility()
		
		for unit in units:
			if unit.get_visibility() > vis:
				vis = unit.get_visibility()
		
		return vis

func get_hiding():
	if len(units) == 0:
		return 0
	else:
		var hide = units[0].get_hiding()
		
		for unit in units:
			if unit.get_hiding() > hide:
				hide = unit.get_hiding()
		
		return hide

func handle_right_click(placement):
	if selected:
		#print("right clicked for course")
		# Turn logic is here for now?
		if Input.is_action_pressed("queue"):
			target_array.append(placement)
			
			emit_signal("new_course_change", current_target, placement)
			#print(target_array)
		elif last_button == "patrol":
			patrolling = true
			current_target = placement
			target_array.append(self.global_position)
			
			emit_signal("new_course_change", current_target, placement)
			
			last_button = ""
			
		elif last_button == "scout" and len(plane_dict["scout"]) > 0:
			# Send planes
			send_out_planes(placement, "scout")
			
			last_button = ""
			
		elif last_button == "strike" and len(plane_dict["strike"]) > 0:
			send_out_planes(placement, "strike")
			
			last_button = ""
		
		elif last_button == "bomb" and len(plane_dict["bomber"]) > 0:
			send_out_planes(placement, "bomber")
			
			last_button = ""
		
		else:
			patrolling = false
			target_array = []
			#var angle = placement.angle_to_point(position) + (PI / 2)
			current_target = placement

func start_placing():
	#print("started placing: " + self.get_name())
	placing = true
	
	global_position = get_viewport().get_mouse_position()
	
	get_node("IslandCollision").disabled = true

func stop_placing():
	#print("stopped placing: " + self.get_name())
	placing = false

	emit_signal("stopped_placing")
	
	get_node("IslandCollision").disabled = false
	#print(get_node("IslandCollision").disabled)
	detector.enable_spotting()
	
	current_target = self.global_position

func select():
	if faction == GameState.get_playerFaction():
		selected = true
		$Sprite.animation = sprite_type + "_clicked"
		$Sprite.set_frame(faction)
		
		emit_signal("squad_selected", self)
		
		last_button = ""
		
func deselect():
	selected = false
	$Sprite.animation = sprite_type + "_basic"
	$Sprite.set_frame(faction)
	
	emit_signal("squad_deselected", self)

func _input(event):
	if selected:
		if Input.is_action_pressed("stop"):
			self.current_target = self.global_position
			self.target_array = []
		elif Input.is_action_pressed("patrol"):
			last_button = "patrol"
		elif Input.is_action_pressed("scout"):
			last_button = "scout"
		elif Input.is_action_pressed("strike"):
			last_button = "strike"
		elif Input.is_action_pressed("bomb"):
			last_button = "bomb"
		elif Input.is_action_pressed("cancel"):
			last_button = ""
			

func _physics_process(delta):
	
	if placing:
		# Place squadron at mouse, until the mouse clicks
		global_position = get_viewport().get_mouse_position()
		current_target = self.global_position
	
	else:
		
		if global_position.distance_to(current_target) < (turn_speed) and len(target_array) > 0:
			#print("updating current target")
			emit_signal("reached_target")
			if patrolling: 
				target_array.append(current_target)
			
			current_target = target_array[0]
			#print(current_target)
			
			target_array.remove(0)
			
		if int(global_position.distance_to(current_target)) > 1:
			self.rotation = lerp_angle(self.rotation, (current_target - self.global_position).normalized().angle() + PI/2, self.turn_weight)
		
		#print(position.move_toward(current_target, delta*current_speed))
		if not stopped:
			self.calc_new_velocity()
			global_position = global_position.move_toward(current_target + applied_wind, delta*(velocity_vector.length()))
		
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func _process(delta):
	
	get_node("HealthBar").value = lerp(get_node("HealthBar").value, get_total_health(), get_process_delta_time())
	get_node("ArmorBar").value = lerp(get_node("ArmorBar").value, get_total_health(), get_process_delta_time())


## COMBAT STUFFS

func get_total_health():
	var tot_health = 0
	
	for u in units:
		tot_health += u.get_health()
	
	return tot_health

func get_total_armor():
	var tot_armor = 0
	
	for u in units:
		tot_armor += u.get_armor()
	
	return tot_armor

func construct_weapon_dict():
	weapon_dict = {} 
	
	for u in units:
		for w in u.get_weapons():
			var fire_rate = str(w.get_fire_rate())
			
			if weapon_dict.has(fire_rate):
				weapon_dict[fire_rate].append(w)
			else:
				weapon_dict[fire_rate] = []
				weapon_dict[fire_rate].append(w)
	
	return weapon_dict

func get_weapon_list():
	var weapon_list = []
	
	for u in units:
		for w in u.get_weapons():
			weapon_list.append(w)
	
	return weapon_list

func set_enemy_squadron(potential_squad):
	#print(potential_squad.get_faction())
	#print(self.faction)
	if potential_squad.get_faction() != self.faction:
		enter_combat(potential_squad)


func exit_combat():
	in_combat = false
	t_crossed = false 
	
	current_shot_count = 0
	
	current_enemy_squadron = null
	
	get_node("ShotTimer").stop()
	
	#print(self.ships)

func enter_combat(enemy_squad):
	print("entered combat!")
	in_combat = true
	t_crossed = false
	
	current_shot_count = 0
	
	current_enemy_squadron = enemy_squad
	
	get_node("ShotTimer").start()

func take_damage(weapon: Weapon, distance_to_squad):
	#print("ships taking damages")
	# for now, the first ship will bear the brunt of the damage. ouch!
	if len(units) <= 0:
		emit_signal("squadron_lost", self, current_enemy_squadron)
	else:
		# Damage Random Ship
		var damage_index = randi() % units.size()
		var damaged_ship = units[damage_index]
		
		# setting this to false until we fix t crossing
		damaged_ship.damage(weapon, false, distance_to_squad)
		
		if damaged_ship.get_health() <= 0:
			emit_signal("ship_lost", units[damage_index])
			units.remove(damage_index)
			
			# update weapon list
			self.weapon_dict = construct_weapon_dict()
			
			if len(units) <= 0:
				emit_signal("squadron_lost", self, current_enemy_squadron)
				print("ship sqaudron lost")
				
	emit_signal("update_squad_info", get_squad_info())

func shoot_guns(weapon_shooting_list, enemy_squadron):
	if enemy_squadron:
		for w in weapon_shooting_list:
			enemy_squadron.take_damage(w, global_position.distance_to(enemy_squadron.global_position))
			enemy_squadron.update_armorbar()
			enemy_squadron.update_healthbar()

func _on_ShotTimer_timeout():
	#check_t_crossed()
	current_shot_count += 1
	#print(weapon_dict)
	
	for f in weapon_dict:
		if current_shot_count % int(f) == 0:
			#print("carrier shooting guns")
			#print("carrier weapons length:" + str(len(weapon_dict[f])))
			shoot_guns(weapon_dict[f], current_enemy_squadron)


# PLANE STUFF

func send_out_planes(placement, type):
	#print(type)
	
	var plane_squad = PlaneSquadScene.instance()
	
	var plane_list = [] 
	# make plane list a copy, not a reference
	for i in range(len(plane_dict[type])):
		plane_list.append(plane_dict[type][i])
	
	var initial_pos = global_position
	var target = placement
	var is_strike = false
	
	# Init plane scene
	# initial posiiton is airbase position
	# plane composition is the scout planes
	# faction
	if type != "scout":
		is_strike = true
	
	print(len(plane_list))
	
	var type_map = {"scout":"scoutPlane",
					"fighter":"fighter",
					"strike":"torpBomber",
					"bomber": "levelBomber"}
	
	if len(plane_list) > 0:
		#print(len(plane_list))
		plane_squad.init(plane_list, initial_pos, faction, "planesquadron")
		plane_squad.set_animation(is_strike, type_map[type])
		plane_squad.set_target(target)
		plane_squad.carrier_launch(self)
		
		emit_signal("plane_launch", plane_squad)
		
		plane_squad.connect("planes_recovered", self, "plane_squad_recovered")
		plane_squad.connect("plane_squad_lost", self, "plane_squad_death")
		
		for i in range(len(plane_dict[type])):
			plane_dict[type].remove(0)
		
		#print("sent planes to ", placement)

func _on_Carrier_area_entered(area):
	print(area.get_name())
	
	if "Island" in area.get_name():
		print("carrier hit island")
		
		hide()
		self.current_target = self.global_position
		self.target_array = []
		
		emit_signal("hit", self)
		
		get_node("IslandCollision").set_deferred("disabled", true)
	
