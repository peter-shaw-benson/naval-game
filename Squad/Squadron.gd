class_name Squadron
extends Area2D

signal new_course_change(current_target, placement)
signal reached_target()
# used when it hits an island
signal hit(Squadron)
# Combat signals
signal squadron_spotted(squad, position)
signal ship_lost(Ship)
signal squandron_left()
signal squadron_lost(squad)

func get_min_speed():
	
	if len(ships) == 0:
		return 0
	else:
		var min_speed = ships[0].get_speed()
		
		for ship in ships:
			if ship.get_speed() < min_speed:
				min_speed = ship.get_speed()
		
		return min_speed

func get_min_turn_weight():
	
	if len(ships) == 0:
		return 0
	else:
		var min_turn_weight = ships[0].get_turn_weight()
		
		for ship in ships:
			if ship.get_turn_weight() < min_turn_weight:
				min_turn_weight = ship.get_turn_weight()
		
		return min_turn_weight

func get_visibility():
	if len(ships) == 0:
		return 0
	else:
		var vis = ships[0].get_visibility()
		
		for ship in ships:
			if ship.get_visibility() > vis:
				vis = ship.get_visibility()
		
		return vis

func get_hiding():
	if len(ships) == 0:
		return 0
	else:
		var hide = ships[0].get_hiding()
		
		for ship in ships:
			if ship.get_hiding() > hide:
				hide = ship.get_hiding()
		
		return hide
		
var ships: Array
var speed: int
var base_speed: int
var turn_speed: int
var turn_weight: float
var initial_pos: Vector2
var task_force_name: String

var visibility: float
var hiding: float

# Combat Vars
var faction = 0
var in_combat = false

var t_crossed = false

var weapon_dict = {}
var stopped = false
var current_shot_count = 0 
var current_enemy_squadron: Squadron

func init(ship_array, initial_position, faction):
	ships = ship_array
	#print(ships[0].speed)
	self.faction = faction
	print("faction ", self.faction)
	
	# for some reason, we need to use deselect() 
	# just don't change it 
	self.deselect()
	
	base_speed = get_min_speed()
	turn_weight = get_min_turn_weight()
	visibility = get_visibility()
	hiding = get_hiding()
	
	# Set up Visibility Collider and Hiding Collider
	var visibility_scale = visibility * 5
	#var hiding_scale = hiding * 10
	
	get_node("Detection Area/CollisionShape2D").shape.radius = visibility_scale
	#get_node("Spotting Area/CollisionShape2D").shape.radius = visibility_scale
	#print("spot radius:", get_node("Spotting Area/CollisionShape2D").shape.radius)
	
	self.initial_pos = initial_position
	self.current_speed = get_min_speed()
	
	self.position = self.initial_pos
	
	# stopped, half, full ahead, flank
	var speed_array = [0, speed / 2, speed, int(speed * 1.2)]
	
	# Combat Variables:
	get_node("ShotTimer").wait_time = GameState.get_combatPace()
	
	# Set max of health bar and Armor Bar
	get_node("HealthBar").set_max(get_total_health())
	get_node("ArmorBar").set_max(get_total_armor())
	
	self.update_healthbar()
	self.update_armorbar()
	self.weapon_dict = construct_weapon_dict()
	
	print("squad created")
	
func select():
	if faction == GameState.get_playerFaction():
		selected = true
		$Sprite.animation = "clicked"
		$Sprite.set_frame(faction)

func deselect():
	selected = false
	$Sprite.animation = "basic"
	$Sprite.set_frame(faction)

func on_click():
	
	if selected:
		self.deselect()
	else:
		self.select()

func get_current_target():
	return current_target

func get_faction():
	return faction

var target_array = []

var current_target = Vector2()
var velocity = Vector2()
var selected = false
var initial_rot = 0
var screen_size
var current_speed

# Why can't this be defined at init?
#var turn_weight = 0.08


# Called when the node enters the scene tree for the first time.
func _ready():
	
	self.rotation = self.initial_rot
	
	self.scale = Vector2(0.6, 0.6)
	
	screen_size = get_viewport_rect().size
	
	current_target = self.global_position
	turn_speed = int(self.base_speed / 2)

func _physics_process(delta):
	
	if global_position.distance_to(current_target) < (turn_speed) and len(target_array) > 0:
		#print("updating current target")
		emit_signal("reached_target")
		
		current_target = target_array[0]
		#print(current_target)
		
		target_array.remove(0)
		
	if int(global_position.distance_to(current_target)) > 1:
		self.rotation = lerp_angle(self.rotation, (current_target - self.global_position).normalized().angle() + PI/2, self.turn_weight)
	
	#print(position.move_toward(current_target, delta*current_speed))
	if not stopped:
		global_position = global_position.move_toward(current_target, delta * current_speed)
	
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == 1 \
	and event.pressed:
		self.on_click()

func _unhandled_input(event):
	
	# Deselct when clicked outside the squadron
	if event is InputEventMouseButton \
	and event.button_index == 1 \
	and event.pressed and self.selected:
		self.deselect()

func handle_right_click(placement):
	if selected:
		#print("right clicked for course")
		# Turn logic is here for now?
		if Input.is_action_pressed("queue"):
			target_array.append(placement)
			
			emit_signal("new_course_change", current_target, placement)
			#print(target_array)
		else:
			target_array = []
			#var angle = placement.angle_to_point(position) + (PI / 2)
			current_target = placement
			

# More input functions, related to hotkeys
func stop(): stopped = true
		
func _on_Squadron_area_entered(area):
	# Entered Hiding Area 
	hide()
	self.current_target = self.global_position
	self.target_array = []
	
	emit_signal("hit", self)
	
	$IslandCollision.set_deferred("disabled", true)

func get_class(): return "Squadron"

func _on_Hiding_Area_area_entered(area):
	print("This Squadron Spotted!")
	emit_signal("squadron_spotted", self, area.global_position)
	
	if self.faction != GameState.get_playerFaction():
		
		show()
	
func _on_Detection_Area_area_exited(area):
	if in_combat == true:
		self.exit_combat()
	
	if self.faction != GameState.get_playerFaction():
		
		hide()

# COMBAT FUNCTIONS

# Gets the total  health of the Squadron
func get_total_health():
	var tot_health = 0
	
	for s in ships:
		tot_health += s.get_health()
	
	return tot_health

func get_total_armor():
	var tot_armor = 0
	
	for s in ships:
		tot_armor += s.get_armor()
	
	return tot_armor

func update_healthbar():
	get_node("HealthBar").value = get_total_health()

func update_armorbar():
	get_node("ArmorBar").value = get_total_armor()

func construct_weapon_dict():
	weapon_dict = {} 
	
	for s in ships:
		for w in s.get_weapons():
			var fire_rate = str(w.get_fire_rate())
			
			if weapon_dict.has(fire_rate):
				weapon_dict[fire_rate].append(w)
			else:
				weapon_dict[fire_rate] = []
				weapon_dict[fire_rate].append(w)
	
	return weapon_dict

func set_enemy_squadron(potential_squad):
	if potential_squad.faction != self.faction:
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
	
	#check_t_crossed()
	
	get_node("ShotTimer").start()

func check_t_crossed():
	
	var enemy_rotaion = current_enemy_squadron.get_rotation_degrees()
	
	var angle_difference = enemy_rotaion - get_rotation_degrees()
	var facing_angle = rad2deg(global_position.angle_to(current_enemy_squadron.global_position))
	
	print("checking crossed T for ", self.faction)
	print(abs(angle_difference - 90))
	print(abs(rotation - facing_angle))
	if abs(angle_difference - 90) < 30:
		if abs(rotation - facing_angle) < 30:
			t_crossed = true
			print("crossed the T!")
	
	else:
		t_crossed = false
	# Enemy squad forward vector perpendicular to yours?
	# Facing (or back to) Enemy Squad 
	
	# Could make this continuous by these two, but that's complex for now

func get_rotation_degrees():
	return self.rotation_degrees
	
func take_damage(weapon: Weapon, distance_to_squad):
	# for now, the first ship will bear the brunt of the damage. ouch!
	if len(ships) <= 0:
		emit_signal("squadron_lost", self, current_enemy_squadron)
	else:
		# Damage Random Ship
		var damage_index = randi() % ships.size()
		var damaged_ship = ships[damage_index]
		
		# setting this to false until we fix t crossing
		damaged_ship.damage(weapon, false, distance_to_squad)
		
		if damaged_ship.get_health() <= 0:
			emit_signal("ship_lost", ships[damage_index])
			ships.remove(damage_index)
			
			if len(ships) <= 0:
				emit_signal("squadron_lost", self, current_enemy_squadron)

func shoot_guns(weapon_shooting_list, enemy_squadron: Squadron):
	for w in weapon_shooting_list:
		enemy_squadron.take_damage(w, global_position.distance_to(enemy_squadron.global_position))
		enemy_squadron.update_armorbar()
		enemy_squadron.update_healthbar()

func _on_ShotTimer_timeout():
	#check_t_crossed()
	current_shot_count += 1
	
	for f in weapon_dict:
		if current_shot_count % int(f) == 0:
			shoot_guns(weapon_dict[f], current_enemy_squadron)
