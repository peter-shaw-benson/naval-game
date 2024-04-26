extends KinematicBody2D
class_name CombatUnit

var unitData: EntityJSON

export var detector_scene: PackedScene
export var Healthbar: PackedScene
export var Turret: PackedScene

var faction_visibility_group = "visible_to_"

var healthbar
var healthbar_offset = Vector2(-15, 30)
var healthbar_offset_scaling_factor = 0.1

# turret type
var turrets = []

signal stopped_placing()

func getSpeed(): 
	return self.unitData.get_speed()
	
func getTurnWeight():
	return self.unitData.get_turn_weight()
	
func getVisibility():
	return self.unitData.get_visibility()
	
func getWindResist():
	return self.unitData.get_wind_resist()
	
func getHiding():
	return self.unitData.get_hiding()
	
signal new_course_change(current_target, placement)
signal reached_target()
signal ship_lost()
signal hit(ship)

signal ship_selected(ship)
signal ship_deselected(ship)

# Combat stuff
var combat_entity
var combat_target
var in_combat = false
var combat_ticks = 0
	
var speed: int
var base_speed: int
var turn_speed: int
var turn_weight: float

# speed, fuel
var speed_mode_dict = {
	"stopped": [0, 0],
	"half": [0.5, 0.2],
	"full": [1, 0.5],
	"flank": [1.5, 1]
}

var current_speed_mode


var visibility: float
var visibility_scaled: float
var hiding: float
var detector: DetectionArea
var wind_resist: float
var spotting_enabled

var fact_string
var visible_string 

# Combat Vars
var faction = 0

# turret stuff:
var firing_target = Vector2(0,0)
var combat_enabled = false

# movement vars
var current_target = Vector2()
var selected = false
var placing = false
var initial_rot = 0
var screen_size

var stopped = false
var patrolling = false
var target_array = []
var target_angle = {"turning": false, "turn_point": Vector2(0,0)}


# ummmm what is the difference between "current speed" and "actual speed"
var current_speed
var actual_speed

var applied_wind: Vector2
var velocity_vector: Vector2

# what kind of combat unit is it?
var type
var sprite_type

# GUI variables
var last_button = ""
var show_path = true


func init(entity, initial_position, faction, type):
	self.unitData = entity
	
	self.type = type
	self.sprite_type = type
	
	#print(ships[0].speed)
	self.faction = faction
	#print("faction ", self.faction)
	
	# for some reason, we need to use deselect() 
	# just don't change it 
	self.deselect()
	
	base_speed = getSpeed()
	turn_weight = getTurnWeight()
	visibility = getVisibility()
	hiding = getHiding()
	self.wind_resist = getWindResist()
	
	# Set up Visibility Collider and Hiding Collider
	visibility_scaled = visibility * GameState.get_visibility_scale()
	#var hiding_scale = hiding * 10
	
	detector = detector_scene.instance()
	detector.init(visibility_scaled, self.faction)
	
	add_child(detector)
	
	fact_string = "faction_" + str(self.faction)
	add_to_group(fact_string)
	visible_string = "visible_to_" + str(self.faction)
	add_to_group(visible_string)
	
	
	self.current_speed = getSpeed()
	self.velocity_vector = Vector2(0, 0)
	
	self.position = initial_position

	self.rotation = self.initial_rot
	turn_speed = int(self.base_speed / 2)
	
	self.applied_wind = Vector2(0, 0)
	# Set max of health bar and Armor Bar
	
	# global setups
	add_to_group("ship")
		
	if self.faction != GameState.get_playerFaction():
		add_to_group("enemy")
	else:
		add_to_group("player")
		
	# a ship should have three groups (flags): ship, faction, animosity
	
	# Combat Variables:
	get_node("ShotTimer").wait_time = GameState.get_combatPace()
	
	#self.scale = Vector2(1.2, 1.2)
	
	screen_size = get_viewport_rect().size
	
	last_button = ""
	
	self.deselect()
	
	stop_moving()
	#print("stopped with the ready method, starting game.")
	
	# create turrets here:
	for w in self.get_weapon_list():
		var turret = Turret.instance()
		
		turret.init(w, faction)
		
		add_child(turret)
		
		turrets.append(turret)
		
	print(turrets)
		
	# Healthbar
	healthbar = Healthbar.instance()
	get_tree().root.add_child(healthbar)
	healthbar.value = self.get_health()
	healthbar.max_value = self.get_health()
	
	setup_specific_unit()
	
func _ready():
	# this has to be called here, cause we need a root scene
	
	if self.faction != GameState.get_playerFaction():
		healthbar.visible = false
		
	get_node("ShotTimer").start()
	
func setup_specific_unit():
	pass
	
#creates new velocity vector with applied wind
func calc_new_velocity():
	# if we don't add the PI/2 here, it will fuck it all up lmao
	var unit_velocity_cartesian = Vector2(current_speed, 0).rotated(global_rotation - PI/2)
	
	self.velocity_vector = unit_velocity_cartesian + 10 * applied_wind

#calculates the wind vector on wind change
func calc_new_wind_vector(wind_cartesian):
	applied_wind = (1 - wind_resist) * wind_cartesian

#calculates movement vector that will be the target in physics_process
func get_movement_vector():
	var temp_current_speed = velocity_vector.length()
	
	return applied_wind + \
	 Vector2(temp_current_speed * cos(global_rotation), \
	 temp_current_speed * sin(global_rotation)).rotated(3*PI/2)

func get_type():
	return self.type

# used for the patrol action
func is_patrolling():
	return false

# graphics: show the green lines?
func set_path_showing(new_showing):
	show_path = new_showing

func get_path_showing():
	return self.show_path
	


	
func set_sprite_type(new_type):
	self.sprite_type = new_type

func on_click():
	if !selected:
		self.select()
		
func get_current_target():
	return current_target

func get_faction():
	return faction





### INPUT EVENTS 
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == 1 \
	and !event.pressed:
		# removing for now
		# print("(combat unit) mouse clicked")
		# this still registers 4 mouse press events per actual mouse click 
		
		self.on_click()

func _unhandled_input(event):
	
	# Deselct when clicked outside the squadron
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and !event.pressed:
		#print("unhandled input")
		if self.selected:
			self.deselect()
		
		if self.placing:
			self.stop_placing()

func start_placing():
	print("started placing: " + self.get_name())
	placing = true
	
	global_position = get_viewport().get_mouse_position()
	
	
func stop_placing():
	#print("stopped placing: " + self.get_name())
	self.deselect()
	
	placing = false

	emit_signal("stopped_placing")
	
	#print(get_node("IslandCollision").disabled)
	detector.enable_spotting()
	
	current_target = self.global_position
	print("stopped placing ship")
#
#	print("visibility: ", visibility, "\t", visibility_scaled)
#	print(detector.get_radius())


## MOVEMENT
func handle_final_turn(turn_point):
	self.target_angle["turning"] = true
	
	self.target_angle["turn_point"] = turn_point

func handle_right_mouse_movement(placement):
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
			
			#print(target_array)
			#print(current_target)
			#print(self.global_position)
			#print("patrolling value:", patrolling)
			
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
			
			#print("ship current target: ", current_target)

func handle_ship_inputs():
	if Input.is_action_pressed("patrol"):
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
	
	elif Input.is_action_pressed("stop"):

		set_current_speed_mode("stopped")
		calc_current_speed()
		self.current_target = self.global_position
		self.target_array = []
		
	
	## COMBAT
	elif Input.is_action_just_pressed("shoot"):
		#print("shooting turrets")
		if selected and combat_enabled:
			self.shoot_turrets()
	
	
	elif Input.is_action_pressed("cancel"):
		last_button = ""


func enable_spotting():
	detector.enable_spotting()
	
	self.spotting_enabled = true
		
func get_health():
	return self.unitData.get_health()

func get_armor():
	return self.unitData.get_armor()
	
	
	
	
	
	
## COMBAT
func unlock_turrets():
	for t in turrets:
		t.unlock()
		
func lock_turrets():
	for t in turrets:
		t.lock()
	
func shoot_turrets():
	
	for t in turrets:
		t.shoot()
		
	
func get_weapon_list():
	return unitData.get_weapons()
	
func enable_combat():
	self.combat_enabled = true

func disable_combat():
	self.combat_enabled = false

func is_plane():
	return false
	
func take_damage(weapon: Weapon):
	
	self.unitData.damage(weapon)
	
	healthbar.value = self.get_health()
	
	if self.get_health() <= 0:
		print("ship lost")
		emit_signal("ship_lost", self)
		
		healthbar.queue_free()
	
func update_healthbar():
	if self.is_in_group("visible_to_" + str(GameState.get_playerFaction())):
		healthbar.visible = true
#
#		# dynamic healthbar offset
#		var scaled_rotation = abs((int(self.rotation_degrees) % 180) - 90)
#		var base_offset = Vector2(-15, 30)
#		healthbar_offset = base_offset - Vector2(0, healthbar_offset_scaling_factor * scaled_rotation)
#
		healthbar.set_global_position(self.global_position + healthbar_offset)
		
		healthbar.set_rotation(0)
	else:
		healthbar.visible = false
	
func scan_detection_radius():
	
	for body in detector.get_overlapping_bodies():
		if body != self and not body.is_in_group(fact_string) and \
		not body.is_in_group(visible_string):
			#print("found body via scan", self.fact_string)
			
			body.call("detect")
			body.add_to_group(visible_string)
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

# mostly handled by turrets autonomously


# Detection:
func detect():
	self.show()
	
func un_detect():
	
	if self.faction != GameState.get_playerFaction():
		self.hide()


## COMMON FUNCS
func start_moving():
	#print("started moving")
	
	stopped = false
	set_current_speed_mode("full")
	calc_current_speed()

func stop_moving():
	stopped = true
	set_current_speed_mode("stopped")


## Selection:
func select():
	
	if self.is_in_group("player"):
		
		selected = true
		get_node("Sprite").animation = type + "_clicked"
		get_node("Sprite").set_frame(faction)
		
		#print(get_node("Sprite").animation)
		
		#print("carrier selected")
		# yikes this might not hold up
		emit_signal("ship_selected", self)
		
		last_button = ""
		
		show_ghost_sprite()

		
func deselect():
	selected = false
	
	get_node("Sprite").animation = type + "_basic"
	get_node("Sprite").set_frame(faction)
	
	#print(get_node("Sprite").animation)
	#print("carrier deselected")
	
	emit_signal("ship_deselected", self)
	
	hide_ghost_sprite()
	
	handle_specific_deselect()
	
	#get_node("ScoutPlaneTriangle").visible = false

func handle_specific_deselect():
	pass

## PHYSICS:
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
