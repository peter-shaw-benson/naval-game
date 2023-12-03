extends "res://Squad/CombatUnitsWrapper.gd"
class_name ShipSquadron

var Fire = preload("res://Weapons/Fire.gd")

signal new_course_change(current_target, placement)
signal reached_target()
signal squadron_lost(this_squad, enemy_squadron)
signal ship_lost(ship)
signal hit(squad)

var t_crossed = false
var target_array = []

var weapon_dict = {}
var stopped = false
var patrolling = false
var current_shot_count = 0 
var current_enemy_squadron: CombatUnitsWrapper
var ship_dict

# fire stuff
var burning_ships = []
var ongoing_fire = Fire.new()
var burning_animation = false

# repairing
var repairing = false

# fuel statistics
var fuel_modifiers = {
	"stopped": 0,
	"half": 0.2,
	"full": 0.5,
	"flank": 1
}

var speed_mode_dict = {
	"stopped": 0,
	"half": 0.5,
	"full": 1,
	"flank": 1.5
}

var current_speed_mode

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Combat Variables:
	get_node("ShotTimer").wait_time = GameState.get_combatPace()
	get_node("Condition Popup").wait_time = GameState.get_combatPace() * 0.8
	
	self.weapon_dict = construct_weapon_dict()
	
	self.scale = Vector2(0.6, 0.6)
	
	screen_size = get_viewport_rect().size
	
	get_node("HealthBar").set_max(get_total_health())
	#get_node("ArmorBar").set_max(get_total_armor())
	
	self.update_healthbar()
	
	last_button = ""
	
	# Make sure it doesn't crash until we're done placing
	get_node("IslandCollision").disabled = true
	
	
	self.deselect()
	
	for ship in units:
		connect("hit_subsystem", self, "on_subsystem_damage")

	# fuel settings
	get_node("FuelBar").max_value = get_max_fuel()
	update_fuel_bar()
	
	stop_moving()
	
func handle_right_click(placement):
	if selected and GameState.get_playerFaction() == get_faction():
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
			
		else:
			patrolling = false
			target_array = []

			# unstops the ship, and also sets the current speed mode
			if stopped:
				start_moving()
				end_repairs()
				
				# flank or half from stop
				if last_button == "flank":
					set_current_speed_mode("flank")
					calc_current_speed()
				
				elif last_button == "half":
					set_current_speed_mode("half")
					calc_current_speed()
				
			# handles setting a current target while already flanking 
			elif get_current_speed_mode() == "flank":
				set_current_speed_mode("flank")
				calc_current_speed()
				
			elif get_current_speed_mode() == "half":
				set_current_speed_mode("half")
				calc_current_speed()
			
			current_target = placement

func _input(event):
	if selected:
		if Input.is_action_pressed("stop"):
			set_current_speed_mode("stopped")
			calc_current_speed()
			self.current_target = self.global_position
			self.target_array = []
		
		elif Input.is_action_pressed("repair"):
			# stop boat
			if not repairing and not current_enemy_squadron:
				start_repairs()
			else:
				end_repairs()
		
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
		
		elif Input.is_action_pressed("cancel"):
			last_button = ""

func start_repairs():
	print("repairing")
	
	self.current_target = self.global_position
	self.target_array = []
	
	stop_moving()
			
	self.repairing = true
	get_node("RepairClock").start()
	
func end_repairs():
	print("stopped repairing")
	
	self.repairing = false
	start_moving()
	
	get_node("RepairClock").stop()

func start_moving():
	print("started moving")
	
	stopped = false
	set_current_speed_mode("full")
	calc_current_speed()
	
	# start fuel timer
	get_node("FuelConsumptionTimer").start()

func stop_moving():
	stopped = true
	set_current_speed_mode("stopped")
	
	# stop fuel timer
	get_node("FuelConsumptionTimer").stop()
	
	update_squad_info()

# Handle Island collisions – this will be different once 
# I implement tile-based islands.
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
		#if distance to target is small and there are queued targets,
		#remove the target from the queue and update the current target
		if global_position.distance_to(current_target) < 10 and len(target_array) > 0:
			emit_signal("reached_target")
			if patrolling: 
				target_array.append(current_target)
			
			current_target = target_array[0]
			
			target_array.remove(0)
		
		#if we are close to the last target, set stopped to true
		elif global_position.distance_to(current_target) < 10:
			emit_signal("reached_target")
			
			stop_moving()

		if int(global_position.distance_to(current_target)) > 1:
			self.rotation = lerp_angle(self.rotation, (current_target - self.global_position).normalized().angle() + PI/2, self.turn_weight)
		#print(position.move_toward(current_target, delta*current_speed))
		if not stopped:
			self.calc_new_velocity()
			global_position = global_position.move_toward(get_movement_vector(), delta*(velocity_vector.length()))
		
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func _process(delta):
	
	get_node("HealthBar").value = lerp(get_node("HealthBar").value, get_total_health(), get_process_delta_time())
	#update_fuel_bar()
	
	var popup_location = Vector2(
		global_position.x + 20,
		global_position.y - 20
	)
	
	get_node("StatusPopups").rect_position = popup_location

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

func get_squadron_max_health(ship_based=false):
	if ship_based:
		var max_h = 0
		
		for ship in units:
			max_h += ship.get_max_health()
		
		return max_h
	else:
		return get_node("HealthBar").max_value

func construct_ship_dict():
	ship_dict = {
		"screen": [],
		"capital": []
	}
	
	for ship in units:
		if ship.get_class() == "Destroyer":
			ship_dict["screen"].append(ship)
		else:
			ship_dict["capital"].append(ship)

func set_enemy_squadron(potential_squad):
	#print(potential_squad.get_faction())
	#print(self.faction)
	if potential_squad.get_faction() != self.faction:
		enter_combat(potential_squad)

func take_plane_damage(plane_squad):
	if plane_squad.get_faction() != self.get_faction():
		
		construct_ship_dict()
		
		self.shoot_guns(self.get_weapon_list(), plane_squad)
		plane_squad.shoot_guns(plane_squad.get_weapon_list(), self)

func exit_combat():
	in_combat = false
	t_crossed = false 
	
	current_shot_count = 0
	
	current_enemy_squadron = null
	
	get_node("ShotTimer").stop()
	get_node("StatusPopups").hide()
	
	#print(self.ships)

func enter_combat(enemy_squad):
	print("entered combat!")
	in_combat = true
	t_crossed = false
	
	current_shot_count = 0
	
	current_enemy_squadron = enemy_squad
	
	get_node("ShotTimer").start()
	
	construct_ship_dict()

func get_damaged_ship():
	# weight towards damaged ships and capitals
	var ship_roll = randf()
	
	var capital_weight = 2
	var damaged_ship_weight = 0.6
	
	var ship_damage_choices
	var num_capitals
	var num_screens
	
	
	if "capital" in ship_dict:
		num_capitals = ship_dict["capital"].size()
	else:
		num_capitals = 0
	
	if "screen" in ship_dict:
		num_screens = ship_dict["screen"].size()
	else:
		num_screens = 0
	
	# screen weight is the ratio of capitals to screens, times the capital weight. 
	# screens will almost always be more.
	var screen_weight
	
	if num_screens == 0:
		screen_weight = 0
	else:
		screen_weight = 1 - ((num_capitals / num_screens) * capital_weight)
	
	if (num_capitals >= num_screens):
		screen_weight = num_screens / num_capitals
	
	if (ship_roll < screen_weight \
	and num_screens > 0) \
	or num_capitals == 0:
		ship_damage_choices = ship_dict["screen"]
	else:
		ship_damage_choices = ship_dict["capital"]
	
	var damaged_ships = []
	var healthy_ships = []
	
	for s in ship_damage_choices:
		if s.get_health() < s.get_max_health():
			damaged_ships.append(s)
		else:
			healthy_ships.append(s)
	
	var ship_roll2 = randf()
	
	if (ship_roll2 < damaged_ship_weight \
	and damaged_ships.size() > 0) \
	or (healthy_ships.size() == 0):
		return damaged_ships[randi() % damaged_ships.size()]
	else:
		return healthy_ships[randi() % healthy_ships.size()]

func take_damage(weapon: Weapon, distance_to_squad, enemy_speed_mode):
	#print("ships taking damages")
	# for now, the first ship will bear the brunt of the damage. ouch!
	if len(units) <= 0:
		emit_signal("squadron_lost", self, current_enemy_squadron)
	else:
		# Damage Random Ship
		var damaged_ship = get_damaged_ship()
		var damage_index = units.find(damaged_ship)
		
		# setting this to false until we fix t crossing
		damaged_ship.damage(weapon, false, distance_to_squad, enemy_speed_mode)
		
		if damaged_ship.on_fire():
			burning_ships.append(damaged_ship)
			
			# display in squad status?
		
		if damaged_ship.get_most_recent_damage() != "healthy"\
		and self.faction == GameState.get_playerFaction():
			on_subsystem_damage(damaged_ship.get_most_recent_damage())
		
		check_ship_removal(damaged_ship, damage_index)
		
		# update speed / weapon stuff
		base_speed = get_min_speed()
		turn_weight = get_min_turn_weight()
		
		self.weapon_dict = construct_weapon_dict()
		
		if self.faction == GameState.get_playerFaction():
			self.show_attack_damage(get_node("HealthBar").value, get_total_health())
		
		update_squad_info(damaged_ship)

func check_ship_removal(damaged_ship, damage_index):
	if damaged_ship.get_health() <= 0:
		emit_signal("ship_lost", damaged_ship)
		units.remove(damage_index)
		
		update_fuel_bar()
			
		if damaged_ship in burning_ships:
			burning_ships.remove(burning_ships.find(damaged_ship))
			
			if burning_ships.size() == 0:

				burning_animation = false
			
			# update weapon list
		self.weapon_dict = construct_weapon_dict()
			
		if len(units) <= 0:
			emit_signal("squadron_lost", self, current_enemy_squadron)
			print("ship sqaudron lost")

func shoot_guns(weapon_shooting_list, enemy_squadron, _stopped=false):
	
	if enemy_squadron and not repairing:
		for w in weapon_shooting_list:
			enemy_squadron.take_damage(w, 
			global_position.distance_to(enemy_squadron.global_position), 
			get_current_speed_mode())

func _on_ShotTimer_timeout():
	#check_t_crossed()
	current_shot_count += 1
	
	for f in weapon_dict:
		if current_shot_count % int(f) == 0:
			shoot_guns(weapon_dict[f], current_enemy_squadron)
			
	if burning_ships.size() > 0:
		#print(burning_ships)
		#print("squadron burning!")
		for ship in burning_ships:
			ship.damage(ongoing_fire, false, -1, "stopped")
			
			check_ship_removal(ship, units.find(ship))

func show_attack_damage(old_health, new_health):
	#print("showing attack damage: " + str(old_health) + "\t" + str(new_health))
	var damage = int(old_health - new_health)
	var damage_str = "-" + str(damage)
	
	#print("showing health popup")
	var popup_location = Vector2(
		global_position.x + 20,
		global_position.y - 20
	)
	
	get_node("StatusPopups").show()
	get_node("StatusPopups").rect_position = popup_location
	
	get_node("StatusPopups").set_health(damage_str)
	
	get_node("Condition Popup").start()
	
func on_subsystem_damage(type):
	# TODO: fully connect this
	
	#print("subsystem damaged:" + type)
	
	var popup_location = Vector2(
		global_position.x + 20,
		global_position.y - 20
	)
	
	var condition_str = type.to_upper()
	
	get_node("StatusPopups").show()
	get_node("StatusPopups").rect_position = popup_location
	
	get_node("StatusPopups").set_condition(condition_str)
	
	get_node("Condition Popup").start()

func _on_Condition_Popup_timeout():
	#print("hiding health popup")
	get_node("StatusPopups").hide()

func _on_RepairClock_timeout():
	#print(str(get_total_health()) + "\t" + str(get_squadron_max_health(true)))
	
	if (get_squadron_max_health(true) - get_total_health()) < 1 \
	and (get_max_fuel() - get_current_fuel()) <= 0.01:
		
		update_squad_info()
		end_repairs()
	
	for ship in units:
		ship.repair()
		
		if ship in burning_ships:
			burning_ships.remove(burning_ships.find(ship))
			
		self.update_healthbar()
		self.update_fuel_bar()
	
	update_squad_info()

func get_status(damaged_ship):
	if repairing:
		return "repairing"
	elif damaged_ship:
		return damaged_ship.get_most_recent_damage()
	elif burning_ships.size() > 0:
		return "burning"
	else:
		return "healthy"

### FUEL PROCESSING

func calc_current_speed():
	
	if out_of_fuel():
		# this will automatically refuel the ship. 
		# the player will have to manually stop repairs to continue.
		start_repairs()
	else:
		current_speed = speed_mode_dict[current_speed_mode] * self.get_min_speed()

func use_fuel(speed_mode):
	
	var fuel_consumption_modifier = fuel_modifiers[speed_mode]
	
	for s in units:
		s.process_fuel(fuel_consumption_modifier)
	
	update_fuel_bar()
		
func set_current_speed_mode(speed_mode):
	current_speed_mode = speed_mode

func get_current_speed_mode():
	return current_speed_mode

func get_current_fuel():
	var current_fuel = 0
	
	for s in units:
		current_fuel += s.get_fuel()
	
	return current_fuel

func get_max_fuel():
	var max_fuel = 0
	
	for s in units:
		max_fuel += s.get_max_fuel()
	
	return max_fuel

func out_of_fuel():
	if get_current_fuel() <= get_max_fuel() * 0.01:
		return true
	else: 
		return false

func update_fuel_bar():
	
	get_node("FuelBar").value = get_current_fuel()

func _on_FuelConsumptionTimer_timeout():
	
	# fuel consumption is in seconds 
	use_fuel(current_speed_mode)
	calc_current_speed()
	
	update_squad_info()
	
func update_squad_info(damaged_ship=null):
	#print("updating squad info")
	
	if selected:
		emit_signal("update_squad_info", get_total_health(), 
					get_current_fuel(), get_status(damaged_ship), get_current_speed_mode())

