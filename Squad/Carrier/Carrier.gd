extends ShipSquadron
class_name Carrier


export var PlaneSquadScene: PackedScene

signal plane_launch(plane_squad)
signal planes_recovered(plane_squad)

var DiveBomber = preload("res://Entities/Planes/DiveBomber.gd")
var TorpBomber = preload("res://Entities/Planes/TorpBomber.gd")
var Fighter = preload("res://Entities/Planes/Fighter.gd")

var CarrierEntity = preload("res://Entities/Ships/CarrierEntity.gd")

var plane_list
var max_planes

var launching = false
var launching_squad

var plane_dict = {"scout": [], "strike": [], "bomber": [], "fighter": []}


var carrier_default_planes = [DiveBomber.new(), TorpBomber.new(), Fighter.new()]


func init(unit_array, initial_position, faction, type):
	plane_list = carrier_default_planes
	units = [CarrierEntity.new()]
	
	sprite_type = type
	type = type
	
	organize_aircraft(plane_list)
	
	#print(ships[0].speed)
	self.faction = faction
	#print("faction ", self.faction)
	
	# for some reason, we need to use deselect() 
	# just don't change it 
	self.deselect()
	
	max_planes = get_max_planes()
	base_speed = get_min_speed()
	turn_weight = get_min_turn_weight()
	visibility = get_visibility()
	hiding = get_hiding()
	self.wind_resist = get_squad_wind_resist()
	
	# Set up Visibility Collider and Hiding Collider
	var visibility_scale = visibility * 5
	#var hiding_scale = hiding * 10
	
	detector = detector_scene.instance()
	detector.init(visibility_scale, faction)
	
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
	
func get_max_planes():
	var temp_max = 0
	
	for u in units:
		temp_max += u.get_max_planes()
	
	return temp_max

func organize_aircraft(plane_list):
	for aircraft in plane_list:
		if aircraft.get_class() == "ScoutPlane":
			plane_dict["scout"].append(aircraft)
		elif aircraft.get_class() == "LevelBomber":
			plane_dict["bomber"].append(aircraft)
		elif aircraft.get_class() == "Fighter":
			plane_dict["fighter"].append(aircraft)
		else:
			plane_dict["strike"].append(aircraft)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	get_node("ShotTimer").wait_time = GameState.get_combatPace()
	get_node("Condition Popup").wait_time = GameState.get_combatPace() * 0.8
	
	self.weapon_dict = construct_weapon_dict()
	#print(weapon_dict)
	
	screen_size = get_viewport_rect().size
	
	get_node("HealthBar").set_max(get_total_health())
	
	self.update_healthbar()
	
	# Make sure it doesn't crash until we're done placing
	get_node("IslandCollision").disabled = true
	# hide launch bar on game start
	get_node("LaunchBar").hide()

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
			send_out_planes(placement, "scout", true)
			
			last_button = ""
			
		elif last_button == "strike" and len(plane_dict["strike"]) > 0:
			send_out_planes(placement, "strike", true)
			
			last_button = ""
		
		elif last_button == "bomb" and len(plane_dict["bomber"]) > 0:
			send_out_planes(placement, "bomber", true)
			
			last_button = ""
			
		elif last_button == "CAP" and len(plane_dict["fighter"]) > 0:
			send_out_planes(placement, "fighter", true, true)
			
			last_button = ""
		
		else:
			patrolling = false
			target_array = []
			#var angle = placement.angle_to_point(position) + (PI / 2)
			current_target = placement

			stopped = false


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
		elif Input.is_action_pressed("fighter"):
			last_button = "CAP"
		elif Input.is_action_pressed("cancel"):
			last_button = ""


func _process(delta):
	
	if launching:
		get_node("LaunchBar").value = get_node("LaunchTimer").time_left
	
	get_node("HealthBar").value = lerp(get_node("HealthBar").value, get_total_health(), get_process_delta_time())


## COMBAT STUFFS

func take_damage(weapon: Weapon, distance_to_squad, enemy_stopped):
	#print("ships taking damages")
	# for now, the first ship will bear the brunt of the damage. ouch!
	if len(units) <= 0:
		emit_signal("squadron_lost", self, current_enemy_squadron)
	else:
		# Damage Random Ship
		var damaged_ship = get_damaged_ship()
		var damage_index = units.find(damaged_ship)
		
		# setting this to false until we fix t crossing
		damaged_ship.damage(weapon, false, distance_to_squad, enemy_stopped)
		
		if damaged_ship.get_health() <= 0:
			emit_signal("ship_lost", damaged_ship)
			units.remove(damage_index)
			
			# update weapon list
			self.weapon_dict = construct_weapon_dict()
			
			if len(units) <= 0:
				emit_signal("squadron_lost", self, current_enemy_squadron)
				print("ship sqaudron lost")
		
		# update speed / weapon stuff
		base_speed = get_min_speed()
		turn_weight = get_min_turn_weight()
		
		self.weapon_dict = construct_weapon_dict()
		
		# Handle Plane Removal
		var current_max_planes = get_max_planes()
		var plane_difference = max_planes - current_max_planes
		
		if current_max_planes == 0:
			plane_list = []
			organize_aircraft(plane_list)
			
		elif plane_difference > 0:
			# Lose planes that are stored away. Won't affect planes sent out. 
			for i in range(plane_difference):
				lose_random_plane()
				
		elif len(plane_list) == 0:
			max_planes = 0
			plane_list = []
			organize_aircraft(plane_list)
				
		max_planes = current_max_planes
				
		if self.faction == GameState.get_playerFaction():
			self.show_attack_damage(get_node("HealthBar").value, get_total_health())
				
	emit_signal("update_squad_info", get_squad_info())

# PLANE STUFF

func get_launch_time(plane_list):
	if len(plane_list) == 0:
		return 0
	else:
		var launch_time = plane_list[0].get_launch_time()
		
		for unit in plane_list:
			if unit.get_launch_time() > launch_time:
				launch_time = unit.get_launch_time()
		
		return launch_time

func _on_Carrier_area_entered(area):
	print(area.get_name())
	
	if "Island" in area.get_name():
		print("carrier hit island")
		
		hide()
		self.current_target = self.global_position
		self.target_array = []
		
		emit_signal("hit", self)
		
		get_node("IslandCollision").set_deferred("disabled", true)
	
func _on_LaunchTimer_timeout():
	end_launch()

func send_out_planes(placement, strike_type, is_carrier_launch=false, is_cap=false):
	#print(type)
	
	if not launching:
	
		var plane_squad = PlaneSquadScene.instance()
		
		var plane_list = [] 
		# make plane list a copy, not a reference
		for i in range(len(plane_dict[strike_type])):
			plane_list.append(plane_dict[strike_type][i])
		
		var initial_pos = global_position
		var target = placement
		var is_strike = false
		
		# Init plane scene
		# initial posiiton is airbase position
		# plane composition is the scout planes
		# faction
		if strike_type != "scout":
			is_strike = true
		
		print(len(plane_list))
		
		var type_map = {"scout":"scoutPlane",
						"strike":"torpBomber",
						"fighter": "fighter",
						"bomber": "levelBomber"}
						
		start_launch(plane_list)
		
		if len(plane_list) > 0:
			#print(len(plane_list))
			plane_squad.init(plane_list, initial_pos, faction, type_map[strike_type])
			plane_squad.set_animation(is_strike, type_map[strike_type])
			plane_squad.set_target(target)
			plane_squad.set_combat_air_patrol(is_cap)
			
			if is_carrier_launch:
				plane_squad.carrier_launch(self)
			
			launching_squad = plane_squad
			get_node("LaunchTimer").start()
			
			for i in range(len(plane_dict[strike_type])):
				plane_dict[strike_type].remove(0)
			
			#print("sent planes to ", placement)


func plane_squad_recovered(plane_squad):
	#print("recovering at base")
	#print(plane_squad)
	#print(plane_squad.get_class())
	#print(plane_squad.get_name())
	var recovered_planes = plane_squad.get_units()
	#print(recovered_planes)
	
	for p in recovered_planes:
		if plane_dict_size() < get_max_planes():
			if plane_squad.get_sprite_type() == "fighter":
				plane_dict["fighter"].append(p)
			elif plane_squad.get_sprite_type() == "levelBomber":
				plane_dict["bomber"].append(p)
			elif plane_squad.get_sprite_type() == "torpBomber":
				plane_dict["strike"].append(p)
			else:
				plane_dict["scout"].append(p)
		else:
			break
	
	plane_squad.queue_free()
		
	emit_signal("planes_recovered", plane_squad)

	#print(plane_dict)

func plane_dict_size():
	return plane_dict["fighter"].size() + \
	plane_dict["scout"].size() + \
	plane_dict["bomber"].size() + \
	plane_dict["strike"].size()

func plane_squad_death(plane_squad):
	plane_squad.queue_free()

func lose_random_plane():
	# only doing fighters and strike planes for now, flipping a coin
	
	plane_list.remove(randi() % plane_list.size())
	
	organize_aircraft(plane_list)
	

func start_launch(plane_list):
	var squad_launch_time = get_launch_time(plane_list)
	get_node("LaunchTimer").wait_time = squad_launch_time
		
	get_node("LaunchBar").show()
	get_node("LaunchBar").max_value = squad_launch_time
		
	launching = true

func end_launch():
	launching = false
	
	emit_signal("plane_launch", launching_squad)
		
	launching_squad.connect("planes_recovered", self, "plane_squad_recovered")
	launching_squad.connect("plane_squad_lost", self, "plane_squad_death")
	
	launching_squad = null
	
	get_node("LaunchBar").hide()
