extends CombatUnit
class_name CarrierScene

# Ship Scene stuff
func get_class(): return "Carrier"

export var TorpedoTube: PackedScene

# this is for placing the ghost sprite
var temp_target = Vector2(0,0)

# fire stuff
var burning_ships = []
# var ongoing_fire = Fire.new()
# ignore fire for now lol
var burning_animation = false

# repairing
var repairing = false


### Airbase Things:
export var PlaneBoidScene: PackedScene

const PlaneBoid = preload("res://Ships2/Planes/PlaneBoid.gd")

signal plane_launch(plane_squad)
signal planes_recovered(plane_squad)

var launching = false
var launching_squad
var launch_type = "scout"
var squad_launch_time = 0.2

var strike_target: Vector2
var scout_targets: Array
var current_scout_plane_launch = 0

var fighter_targets: Array
var current_fighter_plane_launch = 0
var combat_air_patrol = false

var plane_numbers: Dictionary

func _ready():
	pass
	
func setup_specific_unit():
	
	add_to_group("carrier")
	#self.scale = Vector2(1.2, 1.2)
	#print(self.unitData)
	#print(self.unitData.get_planes())
	self.plane_numbers = self.unitData.get_planes()
	#print(self.plane_numbers)
	
	get_node("ScoutPlaneTriangle").visible = false
	get_node("ScoutPlaneTriangle").color = Color(0.2, 0.5, 0.3, 0.3)
	get_node("ScoutPlaneTriangle").scale = Vector2(0.7, 0.7)
	
	scout_targets = get_node("ScoutPlaneTriangle").polygon
	scout_targets.remove(0)
	
	# fighter plane CAP target
	get_node("FighterPatrolCircle").visible = false
	fighter_targets = get_node("FighterPatrolCircle").polygon
	get_node("FighterPatrolCircle").scale = Vector2(0.8, 0.8)
	
	# setup healthbar
	healthbar_offset = Vector2(-15, 35)

func handle_right_click(placement):
	#print("handling right click")
	
	if selected and GameState.get_playerFaction() == get_faction():
		# this works properly for patrols:
		# print("last button:", last_button)
		#print("right clicked for course")
		# Turn logic is here for now?
		
		# Airbase things:
		if last_button == "scout" and plane_numbers["scout"] > 0:
			# Send planes
			self.launch_planes(placement, "scout")
			last_button = ""
			self.combat_air_patrol = false
			
		elif last_button == "strike" and plane_numbers["strike"] > 0:
			self.launch_planes(placement, "strike")
			last_button = ""
			self.combat_air_patrol = false
		
		elif last_button == "bomb" and  plane_numbers["bomber"] > 0:
			self.launch_planes(placement, "bomber")
			
			last_button = ""
			self.combat_air_patrol = false
		
		elif last_button == "CAP" and  plane_numbers["fighter"] > 0:
			
			self.launch_planes(placement, "fighter")
			
			self.combat_air_patrol = true
			
			last_button = ""
		
		else:
			self.handle_right_mouse_movement(placement)
			self.combat_air_patrol = false

func launch_planes(placement, strike_type):
	
	self.send_out_planes(placement, strike_type, true)
	
	#self.stop_moving()

func carrier_inputs():
	handle_ship_inputs()
	
	## Airbase Things
	if Input.is_action_pressed("scout"):
		last_button = "scout"
		
		# show the Scouting Triangle
		if plane_numbers["scout"] > 0:
			get_node("ScoutPlaneTriangle").visible = true
		
	else:
		get_node("ScoutPlaneTriangle").visible = false
		
		if Input.is_action_pressed("strike"):
			last_button = "strike"
		elif Input.is_action_pressed("bomb"):
			last_button = "bomb"
		elif Input.is_action_pressed("fighter"):
			last_button = "CAP"
	
	if Input.is_action_pressed("stop_launch"):
		self.stop_launching()


# change this (hardcode) for now.
# change arrow to the ship type later

	


func handle_specific_deselect():
	get_node("ScoutPlaneTriangle").visible = false

# these are here for later, if we build ports n shit
#func start_repairs():
#	print("repairing")
#
#	self.current_target = self.global_position
#	self.target_array = []
#
#	stop_moving()
#
#	self.repairing = true
#	get_node("RepairClock").start()
#
#func end_repairs():
#	print("stopped repairing")
#
#	self.repairing = false
#	start_moving()
#
#	get_node("RepairClock").stop()
	
# movement functions:
# took out fuel indicators – idk how to do fuel with the new ships.

# Handle Island collisions
func _on_Squadron_area_entered(area):
	if area.get_faction() == 4:
		# Entered Hiding Area 
		hide()
		self.current_target = self.global_position
		self.target_array = []
		
		emit_signal("hit", self)
		
		get_node("IslandCollision").set_deferred("disabled", true)
	
	if area.get_faction() == 5:
		do_fog_effects()

func do_fog_effects():
	print("fog found")
	
func _physics_process(delta):
	
	pass
	#position.x = clamp(position.x, 0, screen_size.x)
	#position.y = clamp(position.y, 0, screen_size.y)

func _process(delta):
	
	draw_ghost_sprite()
	
	
	get_node("ScoutPlaneTriangle").look_at(get_global_mouse_position())
	get_node("ScoutPlaneTriangle").rotation += 3 * PI/4
	
	scout_targets = get_node("ScoutPlaneTriangle").polygon
	scout_targets.remove(0)
	
	fighter_targets = get_node("FighterPatrolCircle").polygon
	
	update_healthbar()
	
	## find overlapping bodies to spot
	scan_detection_radius()
	
	carrier_inputs()
	
	#align_turrets()
	
# if / when we add back fuel, we can use the prototypes in the Ship Squadron class.



## COMBAT
# this is unique to the ships – different for planes
# bugged for now 
#func align_turrets():
#	## TODO
#	var mouse_position = get_global_mouse_position()
#
#	for t in turrets:
#		t.point_to(mouse_position)


## PLANE thingS:

#func _unhandled_input(event):
#	if event is InputEventMouseButton \
#	and event.button_index == BUTTON_RIGHT \
#	and !event.pressed:
#		self.handle_right_click(event.position)

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
	#print(placement, strike_type)
	
	if strike_type == "scout":
		current_scout_plane_launch = 0
	
	if not launching:
		
		var initial_pos = global_position
		strike_target = placement
		#print(initial_pos, strike_target)
		launch_type = strike_type
						
		#print("starting launch")
		start_launch(placement, strike_type)

func start_launch(placement, strike_type):
	launching = true
	
	# hard-coding for now – this means that 2 planes should launch per second
	get_node("LaunchTimer").wait_time = squad_launch_time
	get_node("LaunchTimer").start()
	
	if strike_type != "fighter" and combat_air_patrol == true:
		combat_air_patrol = false
		
	#print(combat_air_patrol, strike_type)

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
	#print(combat_air_patrol, launch_type)
	
	if plane_numbers[launch_type] > 0:
		#spawn new boid
		#print("spawning new plane")
		
		var plane_squad = PlaneBoidScene.instance()
		
		get_tree().root.add_child(plane_squad)
		
		plane_squad.transform = self.global_transform
		
		if launch_type != "scout" and launch_type != "fighter":
			plane_squad.init(launch_type, self, strike_target, self.faction)
			
		elif launch_type == "fighter":
			var patrol_target_idx = current_fighter_plane_launch % len(fighter_targets)
			var patrol_target = fighter_targets[patrol_target_idx]
			
			patrol_target = $FighterPatrolCircle.to_global(patrol_target)
			
			plane_squad.init(launch_type, self, patrol_target, self.faction)
			current_fighter_plane_launch += 1
			
		elif launch_type == "scout":
			
			var scout_target_idx = current_scout_plane_launch % len(scout_targets)
			var scout_target = scout_targets[scout_target_idx]
			
			scout_target = get_node("ScoutPlaneTriangle").to_global(scout_target)
			
			#print(scout_target)
			
			plane_squad.init(launch_type, self, scout_target, self.faction)
			current_scout_plane_launch += 1
			
		plane_squad.connect("plane_recovered", self, "plane_recovered")
		plane_squad.connect("plane_lost", self, "plane_death")
		
		plane_numbers[launch_type] -= 1
		
	elif plane_numbers[launch_type] <= 0 and combat_air_patrol == false:
		stop_launching()

func stop_launching():
	launching = false
	
	combat_air_patrol = false

	get_node("LaunchTimer").stop()

func get_plane_numbers():
	return self.plane_numbers
