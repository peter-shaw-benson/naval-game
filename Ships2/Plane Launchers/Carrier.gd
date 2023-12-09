extends CombatUnit
class_name CarrierScene

# Ship Scene stuff
func get_class(): return "Carrier"

export var Turret: PackedScene
export var TorpedoTube: PackedScene

signal new_course_change(current_target, placement)
signal reached_target()
signal ship_lost()
signal hit(ship)

signal ship_selected(ship)
signal ship_deselected(ship)

var stopped = false
var patrolling = false
var target_array = []
var target_angle = {"turning": false, "turn_point": Vector2(0,0)}

# this is for placing the ghost sprite
var temp_target = Vector2(0,0)

# fire stuff
var burning_ships = []
# var ongoing_fire = Fire.new()
# ignore fire for now lol
var burning_animation = false

# repairing
var repairing = false

# speed, fuel
var speed_mode_dict = {
	"stopped": [0, 0],
	"half": [0.5, 0.2],
	"full": [1, 0.5],
	"flank": [1.5, 1]
}

var current_speed_mode


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

var plane_numbers: Dictionary


func _ready():
	
	var carrier = CarrierEntity.new()
		#var next_destroyer = TorpDestroyer.new()
		#print(next_destroyer)
		
	var carrier_dict = {"ship": carrier,
			"position": Vector2(300, 300),
			"type": "ship",
			"unit_type": "carrier",
			"faction": 0}
	
	self.init(carrier_dict["ship"], carrier_dict["position"], 0, "carrier")
	
	add_to_group("ship")
	add_to_group("carrier")
	
	# add self to proper group (faction)
	if self.faction == 0:
		add_to_group("faction_0")
	elif self.faction == 1:
		add_to_group("faction_1")
	elif self.faction == 2:
		add_to_group("faction_2")
		
	if self.faction != GameState.get_playerFaction():
		add_to_group("enemy")
	else:
		add_to_group("player")
		
	# a ship should have three groups (flags): ship, faction, animosity
	
	# Combat Variables:
	get_node("ShotTimer").wait_time = GameState.get_combatPace()
	
	self.scale = Vector2(1.2, 1.2)
	
	screen_size = get_viewport_rect().size
	
	last_button = ""
	
	self.deselect()
	
	stop_moving()
	#print("stopped with the ready method, starting game.")
	
	# create turrets here:
	for w in self.get_weapon_list():
		var turret = Turret.instance()
		
		turret.init(w)
		
		add_child(turret)
		
		turrets.append(turret)
	
	print(self.unitData)
	print(self.unitData.get_planes())
	self.plane_numbers = self.unitData.get_planes()
	print(self.plane_numbers)
	
	get_node("ScoutPlaneTriangle").visible = false
	get_node("ScoutPlaneTriangle").color = Color(0.2, 0.5, 0.3, 0.3)
	
	scout_targets = get_node("ScoutPlaneTriangle").polygon
	scout_targets.remove(0)
	
	# fighter plane CAP target
	get_node("FighterPatrolCircle").visible = false
	fighter_targets = get_node("FighterPatrolCircle").polygon
	get_node("FighterPatrolCircle").scale = Vector2(0.8, 0.8)
	
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
			
		elif last_button == "strike" and plane_numbers["strike"] > 0:
			self.launch_planes(placement, "strike")
			last_button = ""
		
		elif last_button == "bomb" and  plane_numbers["bomber"] > 0:
			self.launch_planes(placement, "bomber")
			
			last_button = ""
		
		elif last_button == "CAP" and  plane_numbers["fighter"] > 0:
			
			self.launch_planes(placement, "fighter")
			
			last_button = ""
		
		### Ship things:
		if Input.is_action_pressed("queue"):
			target_array.append(placement)
			
			emit_signal("new_course_change", current_target, placement)
			#print(target_array)
			
		elif last_button == "patrol":
			print("patrolling")
			patrolling = true
			current_target = placement
			target_array.append(self.global_position)
			
			print(target_array)
			print(current_target)
			print(self.global_position)
			print("patrolling value:", patrolling)
			
			emit_signal("new_course_change", current_target, placement)
			
			last_button = ""
			
			# need to start moving when you begin a patrol...
			if stopped:
				start_moving()
			
		else:
			patrolling = false
			target_array = []
			#print("stopped patrolling for some reason?")

			# unstops the ship, and also sets the current speed mode
			if stopped:
				start_moving()
				#end_repairs()
				
				# flank or half from stop
				if last_button == "flank" || last_button == "half":
					set_current_speed_mode(last_button)
					calc_current_speed()
	
				
			# handles setting a current target while already flanking 
			elif get_current_speed_mode() == "flank" || get_current_speed_mode() == "half":
				set_current_speed_mode(get_current_speed_mode())
			
			current_target = placement


func launch_planes(placement, strike_type):
	
	self.send_out_planes(placement, strike_type, true)
	
	#self.stop_moving()

func handle_final_turn(turn_point):
	self.target_angle["turning"] = true
	
	self.target_angle["turn_point"] = turn_point
	
	#print(self.target_angle)

func _input(event):
	if selected:
		
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
		
		if Input.is_action_pressed("stop"):
			self.stop_launching()
			set_current_speed_mode("stopped")
			calc_current_speed()
			self.current_target = self.global_position
			self.target_array = []
		
		elif Input.is_action_pressed("patrol"):
			last_button = "patrol"
			
		elif Input.is_action_pressed("flank speed"):
			last_button = "flank"
			
			# set speed to be higher here
			set_current_speed_mode("flank")
			calc_current_speed()
		
		elif Input.is_action_pressed("half speed"):
			last_button = "half"
			
			# set speed to be half here
			set_current_speed_mode("half")
			calc_current_speed()
		
		elif Input.is_action_pressed("full ahead"):
			last_button = "full"
			
			# set speed to be full here
			set_current_speed_mode("full")
			calc_current_speed()
			
		
		## COMBAT
		elif Input.is_action_just_pressed("shoot"):
			#print("shooting turrets")
			if selected and combat_enabled:
				self.shoot_turrets()
		
		
		elif Input.is_action_pressed("cancel"):
			last_button = ""

# change this (hardcode) for now.
# change arrow to the ship type later

func select():
	
	if self.is_in_group("player"):
		
		selected = true
		get_node("CarrierSprite").animation = type + "_clicked"
		get_node("CarrierSprite").set_frame(faction)
		
		#print(get_node("Sprite").animation)
		
		print("carrier selected")
		# yikes this might not hold up
		emit_signal("ship_selected", self)
		
		last_button = ""
		
		unlock_turrets()
		
		show_ghost_sprite()
		
func deselect():
	selected = false
	
	get_node("CarrierSprite").animation = type + "_basic"
	get_node("CarrierSprite").set_frame(faction)
	
	lock_turrets()
	
	#print(get_node("Sprite").animation)
	print("carrier deselected")
	
	emit_signal("ship_deselected", self)
	
	hide_ghost_sprite()
	
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
func start_moving():
	#print("started moving")
	
	stopped = false
	set_current_speed_mode("full")
	calc_current_speed()

func stop_moving():
	stopped = true
	set_current_speed_mode("stopped")

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
	
	if placing:
		# Place squadron at mouse, until the mouse clicks
		global_position = get_viewport().get_mouse_position()
		current_target = self.global_position
	
	else:
		
		var movement_vector = Vector2(0,0)
		#if distance to target is small and there are queued targets,
		#remove the target from the queue and update the current target
		
		
		#print("patrolling, target array:", target_array)
		if global_position.distance_to(current_target) < 10 and len(target_array) > 0:
			emit_signal("reached_target")
			
			if patrolling: 
				target_array.append(current_target)
				#print("patrolling, target array:", target_array)
			
			current_target = target_array[0]
			
			target_array.remove(0)
		
		#if we are close to the last target, set stopped to true
		elif global_position.distance_to(current_target) < 10:
			
			emit_signal("reached_target")
			
			stop_moving()

		if int(global_position.distance_to(current_target)) > 1 and not stopped:
			self.rotation = lerp_angle(self.rotation, (current_target - self.global_position).normalized().angle() + PI/2, self.turn_weight)

		if not stopped:
			self.calc_new_velocity()
			
			velocity_vector = move_and_slide(self.velocity_vector)
			
		elif self.target_angle["turning"]:
			var angle_to_turn_target = (target_angle["turn_point"] - self.global_position).normalized().angle() + PI/2
			
			self.global_rotation = lerp_angle(self.global_rotation, angle_to_turn_target, self.turn_weight)
			# recycling some code earlier – couldn't figure it out any other way
			
			if abs(angle_to_turn_target - self.global_rotation) <= 0.01:
				# if we reached the turn targe,t stope turning
				self.target_angle["turning"] = false
				self.target_angle["turn_point"] = self.global_position
	
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func _process(delta):
	
	draw_ghost_sprite()
	
	
	get_node("ScoutPlaneTriangle").look_at(get_global_mouse_position())
	get_node("ScoutPlaneTriangle").rotation += 3 * PI/4
	
	scout_targets = get_node("ScoutPlaneTriangle").polygon
	scout_targets.remove(0)
	
	fighter_targets = get_node("FighterPatrolCircle").polygon

	
func set_firing_target(firing_target):
	
	# idk how to do this one yet
	self.firing_target = firing_target

# update this later, once turrets are added
func _on_ShotTimer_timeout():
	
	pass
	
# TODO: make a bullet deal damage.
func take_damage(weapon: Weapon):
	
	self.unitData.damage(weapon)
	
	if self.get_health() <= 0:
		print("ship lost")
		emit_signal("ship_lost", self)

# if / when we add back fuel, we can use the prototypes in the Ship Squadron class.

func set_current_speed_mode(speed_mode):
	current_speed_mode = speed_mode

func get_current_speed_mode():
	return current_speed_mode

func calc_current_speed():
	
	#if out_of_fuel():
		# this will automatically refuel the ship. 
		# the player will have to manually stop repairs to continue.
	#	start_repairs()

	current_speed = speed_mode_dict[current_speed_mode][0] * self.getSpeed()




## COMBAT
# this is unique to the ships – different for planes
# bugged for now 
#func align_turrets():
#	## TODO
#	var mouse_position = get_global_mouse_position()
#
#	for t in turrets:
#		t.point_to(mouse_position)


func draw_ghost_sprite():
	# here, we put the position of the ghost sprite over the mouse
	# then, if the right mouse is already being held down, 
	# we rotate the sprite so it's facing the right mouse
	
	var ghost_sprite = get_node("GhostSprite")
	
	# sets the alpha value to be very low
	ghost_sprite.self_modulate.a = 0.2
	
	ghost_sprite.global_position = get_global_mouse_position()
	
	if Input.is_action_pressed("right_click"):
		#print("rotating ghost sprite")
		# ideally, this should stick on the temp target
		ghost_sprite.global_position = self.temp_target
		ghost_sprite.look_at(get_global_mouse_position())
		ghost_sprite.rotation += PI/2
	
func hide_ghost_sprite():
	#print("hiding ghost sprite")
	get_node("GhostSprite").visible = false

func show_ghost_sprite():
	get_node("GhostSprite").visible = true

func set_temp_target(new_temp_target):
	self.temp_target = new_temp_target

func get_temp_target():
	return self.temp_target


## PLANE thingS:

func _unhandled_input(event):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_RIGHT \
	and !event.pressed:
		self.handle_right_click(event.position)

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
		print(initial_pos, strike_target)
		launch_type = strike_type
						
		print("starting launch")
		start_launch(placement, strike_type)

func start_launch(placement, strike_type):
	launching = true
	
	# hard-coding for now – this means that 2 planes should launch per second
	get_node("LaunchTimer").wait_time = squad_launch_time
	get_node("LaunchTimer").start()

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
		#print("spawning new plane")
		
		var plane_squad = PlaneBoidScene.instance()
		
		get_tree().root.add_child(plane_squad)
		
		plane_squad.transform = self.global_transform
		
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

	get_node("LaunchTimer").stop()

func get_plane_numbers():
	return self.plane_numbers
