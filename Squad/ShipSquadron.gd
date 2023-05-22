extends "res://Squad/CombatUnitsWrapper.gd"
class_name ShipSquadron

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

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Combat Variables:
	get_node("ShotTimer").wait_time = GameState.get_combatPace()
	get_node("StatusPopups/Condition Popup").wait_time = GameState.get_combatPace() * 0.8
	
	self.weapon_dict = construct_weapon_dict()
	
	self.scale = Vector2(0.6, 0.6)
	
	screen_size = get_viewport_rect().size
	
	get_node("HealthBar").set_max(get_total_health())
	#get_node("ArmorBar").set_max(get_total_armor())
	
	self.update_healthbar()
	#self.update_armorbar()
	
	last_button = ""
	
	# Make sure it doesn't crash until we're done placing
	get_node("IslandCollision").disabled = true
	
	self.deselect()
	
	for ship in units:
		connect("hit_subsystem", self, "on_subsystem_damage")

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
			
		else:
			patrolling = false
			target_array = []
			#var angle = placement.angle_to_point(position) + (PI / 2)
			stopped = false
			current_target = placement

func _input(event):
	if selected:
		if Input.is_action_pressed("stop"):
			self.current_target = self.global_position
			self.target_array = []
		
		elif Input.is_action_pressed("patrol"):
			last_button = "patrol"
		
		elif Input.is_action_pressed("cancel"):
			last_button = ""

# Handle Island collisions
func _on_Squadron_area_entered(area):
	if area.get_faction() == 4:
		# Entered Hiding Area 
		hide()
		self.current_target = self.global_position
		self.target_array = []
		
		emit_signal("hit", self)
		
		get_node("IslandCollision").set_deferred("disabled", true)

	
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
			stopped = true

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
	
	var popup_location = Vector2(
		global_position.x + 20,
		global_position.y - 20
	)
	
	get_node("StatusPopups/PopupHealth").rect_position = popup_location
	
	var popup_location2 = Vector2(
		global_position.x + 20,
		global_position.y 
	)
	
	get_node("StatusPopups/PopupConditions").rect_position = popup_location

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
	get_node("StatusPopups/PopupHealth").hide()
	
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
		
		# update speed / weapon stuff
		base_speed = get_min_speed()
		turn_weight = get_min_turn_weight()
		
		self.weapon_dict = construct_weapon_dict()
		
		if self.faction == GameState.get_playerFaction():
			self.show_attack_damage(get_node("HealthBar").value, get_total_health())
				
	emit_signal("update_squad_info", get_squad_info())

func shoot_guns(weapon_shooting_list, enemy_squadron):
	if enemy_squadron:
		for w in weapon_shooting_list:
			enemy_squadron.take_damage(w, global_position.distance_to(enemy_squadron.global_position))

func _on_ShotTimer_timeout():
	#check_t_crossed()
	current_shot_count += 1
	
	for f in weapon_dict:
		if current_shot_count % int(f) == 0:
			shoot_guns(weapon_dict[f], current_enemy_squadron)

func show_attack_damage(old_health, new_health):
	#print("showing attack damage: " + str(old_health) + "\t" + str(new_health))
	var damage = int(old_health - new_health)
	var damage_str = "-" + str(damage)
	
	#print("showing health popup")
	var popup_location = Vector2(
		global_position.x + 20,
		global_position.y - 20
	)
	
	get_node("StatusPopups/PopupHealth").show()
	get_node("StatusPopups/PopupHealth").rect_position = popup_location
	get_node("StatusPopups/PopupHealth/HealthText").text = damage_str
	
	get_node("StatusPopups/Condition Popup").start()
	
func on_subsystem_damage(type):
	print("subsystem damaged:" + type)
	
	var popup_location = Vector2(
		global_position.x + 20,
		global_position.y 
	)
	
	var condition_str = type.to_upper()
	
	get_node("StatusPopups/PopupConditions").show()
	get_node("StatusPopups/PopupConditions").rect_position = popup_location
	get_node("StatusPopups/PopupConditions/ConditionText").text = condition_str
	
	get_node("Condition Popup").start()


func _on_Condition_Popup_timeout():
	#print("hiding health popup")
	get_node("PopupHealth").hide()
	get_node("PopupConditions").hide()
