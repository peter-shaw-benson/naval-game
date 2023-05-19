extends "res://Squad/CombatUnitsWrapper.gd"
class_name Airbase

export var PlaneSquadScene: PackedScene

const ScoutPlane = preload("res://Entities/Planes/ScoutPlane.gd")

signal plane_launch(plane_squad)
signal planes_recovered(plane_squad)

var scout_plane_list = [ScoutPlane.new()]

var airbase_health = 500
var airbase_armor = 100

var launching = false
var launching_squad

var plane_dict = {"scout": [], "strike": [], "bomber": [], "fighter": []}

func _ready():
	self.deselect()
	
	self.scale = Vector2(0.6, 0.6)
	
	last_button = ""

func _process(delta):
	if placing:
		# Place squadron at mouse, until the mouse clicks
		global_position = get_viewport().get_mouse_position()
		
	if launching:
		get_node("LaunchBar").value = get_node("LaunchTimer").time_left
	

func init(plane_list, initial_pos, faction, type):
	global_position = initial_pos
	
	plane_list = plane_list
	
	type = type
	
	organize_aircraft(plane_list)
	self.faction = faction
	
	print("airbase faction:")
	print(self.faction)
	
	visibility = get_visibility()
	
	var visibility_scale = visibility * 5
	#var hiding_scale = hiding * 10
	
	detector = detector_scene.instance()
	detector.init(visibility_scale)
	
	add_child(detector)
	
	detector.connect("entered_spotting_area", self, "on_detection_entered")
	detector.connect("left_spotting_area", self, "on_detection_left")
	
	self.deselect()

func get_visibility():
	return 10
func get_min_speed():
	return 0
func get_total_health():
	return airbase_health
func get_total_armor():
	return airbase_armor

func start_placing():
	placing = true
	
	global_position = get_viewport().get_mouse_position()
	
func stop_placing():
	placing = false
	
	emit_signal("stopped_placing")
	
	current_target = self.global_position
	
	enable_spotting()


func select():
	if faction == GameState.get_playerFaction():
		
		self.selected = true
		
		emit_signal("airbase_selected", self)
		
		get_node("ColorRect").show()

func deselect():
	
	self.selected = false
	
	emit_signal("airbase_deselected", self)
	
	get_node("ColorRect").hide()

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
	
	#print(plane_dict)
	#print(plane_dict["bomber"])


# Press "S" for scouting, press Z for strike
# for now, scouting force is 2 scout planes 
# while strike force is 
func handle_right_click(placement):
	if selected:
		#print("right clicked for course")
		# Turn logic is here for now?
		#print(plane_dict)
		
		if last_button == "scout" and len(plane_dict["scout"]) > 0:
			# Send planes
			send_out_planes(placement, "scout")
			
			last_button = ""
			
		elif last_button == "strike" and len(plane_dict["strike"]) > 0:
			send_out_planes(placement, "strike")
			
			last_button = ""
		
		elif last_button == "bomb" and len(plane_dict["bomber"]) > 0:
			send_out_planes(placement, "bomber")
			
			last_button = ""
		
		elif last_button == "CAP" and len(plane_dict["fighter"]) > 0:
			send_out_planes(placement, "fighter", true)
			
			last_button = ""

func _input(event):
	if selected:
		if Input.is_action_pressed("scout"):
			last_button = "scout"
		elif Input.is_action_pressed("strike"):
			last_button = "strike"
		elif Input.is_action_pressed("bomb"):
			last_button = "bomb"
		elif Input.is_action_pressed("fighter"):
			last_button = "CAP"
		elif Input.is_action_pressed("cancel"):
			last_button = ""

# Combat stuff:
func take_plane_damage(plane_squad):
	pass

func set_enemy_squadron(enemy_squad):
	pass


### PLANE STUFF:
func get_launch_time(plane_list):
	if len(plane_list) == 0:
		return 0
	else:
		var launch_time = plane_list[0].get_launch_time()
		
		for unit in plane_list:
			if unit.get_launch_time() > launch_time:
				launch_time = unit.get_launch_time()
		
		return launch_time

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
		if plane_squad.get_sprite_type() == "fighter":
			plane_dict["fighter"].append(p)
		elif plane_squad.get_sprite_type() == "levelBomber":
			plane_dict["bomber"].append(p)
		elif plane_squad.get_sprite_type() == "torpBomber":
			plane_dict["strike"].append(p)
		else:
			plane_dict["scout"].append(p)
	
	plane_squad.queue_free()
		
	emit_signal("planes_recovered", plane_squad)

	#print(plane_dict)

func plane_squad_death(plane_squad):
	plane_squad.queue_free()

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

func _on_LaunchTimer_timeout():
	end_launch()
