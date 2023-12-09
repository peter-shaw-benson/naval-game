extends "res://Ships2/CombatUnit.gd"
class_name Airbase

export var PlaneSquadScene: PackedScene
export var PlaneBoidScene: PackedScene

const ScoutPlane = preload("res://Entities/Planes/ScoutPlane.gd")
const PlaneBoid = preload("res://Ships2/Planes/PlaneBoid.gd")

signal plane_launch(plane_squad)
signal planes_recovered(plane_squad)

var scout_plane_list = [ScoutPlane.new()]

var airbase_health = 500
var airbase_armor = 100

var launching = false
var launching_squad
var launch_type = "scout"
var squad_launch_time = 0.2

var strike_target: Vector2
var scout_targets: Array
var current_scout_plane_launch = 0

var fighter_targets: Array
var current_fighter_plane_launch = 0

var plane_numbers = {"scout": 10, "strike": 20, "bomber": 0, "fighter": 30}

func _ready():
	self.deselect()
	
	self.scale = Vector2(0.6, 0.6)
	
	last_button = ""
	
	add_to_group("airbase")
	
	get_node("ScoutPlaneTriangle").visible = false
	get_node("ScoutPlaneTriangle").color = Color(0.2, 0.5, 0.3, 0.3)
	
	scout_targets = get_node("ScoutPlaneTriangle").polygon
	scout_targets.remove(0)
	
	# fighter plane CAP target
	get_node("FighterPatrolCircle").visible = false
	fighter_targets = get_node("FighterPatrolCircle").polygon

func _process(delta):
	if placing:
		# Place squadron at mouse, until the mouse clicks
		global_position = get_viewport().get_mouse_position()
		
	if launching:
		get_node("LaunchBar").value = get_node("LaunchTimer").time_left
	
	get_node("ScoutPlaneTriangle").look_at(get_global_mouse_position())
	get_node("ScoutPlaneTriangle").rotation += 3 * PI/4
	
	scout_targets = get_node("ScoutPlaneTriangle").polygon
	scout_targets.remove(0)
	
	fighter_targets = get_node("FighterPatrolCircle").polygon

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
	
	get_node("LaunchBar").hide()
	get_node("LaunchTimer").stop()

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
	#print("airbase selected")
	if faction == GameState.get_playerFaction():
		
		self.selected = true
		
		emit_signal("airbase_selected", self)
		
		get_node("ColorRect").show()

func deselect():
	
	self.selected = false
	
	emit_signal("airbase_deselected", self)
	
	get_node("ColorRect").hide()
	get_node("ScoutPlaneTriangle").visible = false

func organize_aircraft(plane_list):
	for aircraft in plane_list:
		if aircraft.get_class() == "ScoutPlane":
			plane_numbers["scout"] += 1
		elif aircraft.get_class() == "LevelBomber":
			plane_numbers["bomber"] += 1
		elif aircraft.get_class() == "Fighter":
			plane_numbers["fighter"] += 1
		else:
			plane_numbers["strike"] += 1



func _unhandled_input(event):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_RIGHT \
	and !event.pressed:
		self.handle_right_click(event.position)

# Press "S" for scouting, press Z for strike
# for now, scouting force is 2 scout planes 
# while strike force is 
func handle_right_click(placement):
	if selected:
		#print("right clicked for course")
		# Turn logic is here for now?
		#print(plane_numbers)
		
		if last_button == "scout" and plane_numbers["scout"] > 0:
			# Send planes
			send_out_planes(placement, "scout")
			current_scout_plane_launch = 0
			
			last_button = ""
			
		elif last_button == "strike" and plane_numbers["strike"] > 0:
			send_out_planes(placement, "strike")
			
			last_button = ""
		
		elif last_button == "bomb" and plane_numbers["bomber"] > 0:
			send_out_planes(placement, "bomber")
			
			last_button = ""
		
		elif last_button == "CAP" and plane_numbers["fighter"] > 0:
			send_out_planes(placement, "fighter", true)
			
			last_button = ""

func _input(event):
	if selected:
		if Input.is_action_pressed("scout"):
			last_button = "scout"
			
			# show the Scouting Triangle
			get_node("ScoutPlaneTriangle").visible = true
			
		else:
			get_node("ScoutPlaneTriangle").visible = false
			
			if Input.is_action_pressed("strike"):
				last_button = "strike"
			elif Input.is_action_pressed("bomb"):
				last_button = "bomb"
			elif Input.is_action_pressed("fighter"):
				last_button = "CAP"
			elif Input.is_action_pressed("stop"):
				stop_launching()
				
			elif Input.is_action_pressed("cancel"):
				last_button = ""
		
		#print(last_button)

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

func send_out_planes(placement, strike_type, is_cap=false):
	print(placement, strike_type)
	
	if strike_type == "scout":
		current_scout_plane_launch = 0
	
	if not launching:
		
		var initial_pos = global_position
		strike_target = placement
		launch_type = strike_type
						
		print("starting launch")
		start_launch(placement, strike_type)
		
func start_launch(placement, strike_type):
	launching = true
	
	# hard-coding for now – this means that 2 planes should launch per second
	get_node("LaunchTimer").wait_time = squad_launch_time
	get_node("LaunchTimer").start()
		
	get_node("LaunchBar").show()
	get_node("LaunchBar").max_value = squad_launch_time

func plane_recovered(plane):
	var recovered_plane_type = plane.get_plane_type()
	
	self.plane_numbers[recovered_plane_type] += 1
	
	plane.queue_free()

func plane_squad_death(plane_squad):
	plane_squad.queue_free()

func end_launch():
	launching = false
	
	emit_signal("plane_launch", launching_squad)
		
	launching_squad.connect("plane_recovered", self, "plane_squad_recovered")
	launching_squad.connect("plane_squad_lost", self, "plane_squad_death")
	
	launching_squad = null
	
	get_node("LaunchBar").hide()

func _on_LaunchTimer_timeout():
	#end_launch()
	# spawn new boid
	#print(launch_type, plane_numbers[launch_type])
	
	if plane_numbers[launch_type] > 0:
		#spawn new boid
		print("spawning new plane")
		
		var plane_squad = PlaneBoidScene.instance()
		
		add_child(plane_squad)
		
		
		if launch_type != "scout" and launch_type != "fighter":
			plane_squad.init(launch_type, self.global_position, strike_target)
			
		elif launch_type == "fighter":
			var patrol_target_idx = current_fighter_plane_launch % len(fighter_targets)
			var patrol_target = fighter_targets[patrol_target_idx]
			
			patrol_target = $FighterPatrolCircle.to_global(patrol_target)
			
			plane_squad.init(launch_type, self.global_position, patrol_target)
			current_fighter_plane_launch += 1
			
		elif launch_type == "scout":
			var scout_target_idx = current_scout_plane_launch % len(scout_targets)
			var scout_target = scout_targets[scout_target_idx]
			
			scout_target = $ScoutPlaneTriangle.to_global(scout_target)
			
			plane_squad.init(launch_type, self.global_position, scout_target)
			current_scout_plane_launch += 1
			
		plane_squad.connect("plane_recovered", self, "plane_recovered")
		plane_squad.connect("plane_lost", self, "plane_death")
		
		plane_numbers[launch_type] -= 1
		
	else:
		stop_launching()

func stop_launching():
	launching = false
	get_node("LaunchBar").hide()
	get_node("LaunchTimer").stop()

func get_plane_numbers():
	return self.plane_numbers
