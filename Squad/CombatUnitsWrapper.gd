extends Area2D
class_name CombatUnitsWrapper

export var detector_scene: PackedScene

# signals
signal stopped_placing()
signal squad_selected(squad)
signal squad_deselected(squad)
signal update_squad_info(new_info)

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

func get_max_range():
	if len(units) == 0:
		return 0
	else:
		var max_r = units[0].get_range()
		
		for unit in units:
			if unit.get_range() < max_r:
				max_r = unit.get_range()
		
		return max_r

#wind resist is average of all unit wind resists
func get_squad_wind_resist():
	if len(units) == 0:
		return 0
	else:
		var resist = 0
		var i = 0
		while i < len(units):
			resist += units[i].get_wind_resist()
			i += 1
		return resist / i

var units: Array
var speed: int
var max_range: int
var base_speed: int
var turn_speed: int
var turn_weight: float
var initial_pos: Vector2
var task_force_name: String
var sprite_type: String

var visibility: float
var hiding: float
var detector: DetectionArea
var wind_resist: float

# Combat Vars
var faction = 0
var in_combat = false

var current_target = Vector2()
var selected = false
var placing = false
var initial_rot = 0
var screen_size
var current_speed
var actual_speed
var applied_wind: Vector2
var velocity_vector: Vector2

# what kind of combat unit is it?
var type

# GUI variables
var last_button = ""
var show_path = true

func init(unit_array, initial_position, faction, type):
	self.type = type
	self.sprite_type = type
	
	units = unit_array
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
	max_range = get_max_range()
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

#creates new velocity vector with applied wind
func calc_new_velocity():
	var unit_velocity_cartesian = Vector2(current_speed * cos(global_rotation), current_speed * sin(global_rotation))
	self.velocity_vector = unit_velocity_cartesian + 10 * applied_wind

#calculates the wind vector on wind change
func calc_new_wind_vector(wind_cartesian):
	applied_wind = (1 - wind_resist) * wind_cartesian

#calculates movement vector that will be the target in physics_process
func get_movement_vector():
	var current_speed = velocity_vector.length()
	return global_position + applied_wind + \
	 Vector2(current_speed * cos(global_rotation), \
	 current_speed * sin(global_rotation)).rotated(3*PI/2)

func get_units():
	return self.units

func get_type():
	return self.type

func is_patrolling():
	return false

func set_path_showing(new_showing):
	show_path = new_showing

func get_path_showing():
	return self.show_path

func select():
	if faction == GameState.get_playerFaction():
		selected = true
		get_node("Sprite").animation = sprite_type + "_clicked"
		get_node("Sprite").set_frame(faction)
		
		print(get_node("Sprite").animation)
		
		emit_signal("squad_selected", self)
		
		last_button = ""
		
func deselect():
	selected = false
	get_node("Sprite").animation = sprite_type + "_basic"
	get_node("Sprite").set_frame(faction)
	
	#print(get_node("Sprite").animation)
	
	emit_signal("squad_deselected", self)

func set_sprite_type(new_type):
	self.sprite_type = new_type

func on_click():
	if selected:
		self.deselect()
	else:
		self.select()
		
func get_current_target():
	return current_target

func get_faction():
	return faction

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == 1 \
	and event.pressed:
		self.on_click()

func _unhandled_input(event):
	
	# Deselct when clicked outside the squadron
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		if self.selected:
			self.deselect()
		
		if self.placing:
			self.stop_placing()

func start_placing():
	print("started placing: " + self.get_name())
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

func enable_spotting():
	detector.enable_spotting()

func set_enemy_squadron(potential_squad):
	#print(potential_squad.get_faction())
	#print(self.faction)
	#if potential_squad.get_faction() != self.faction:
	#	enter_combat(potential_squad)
	pass

func on_detection_entered(other_thing):
	
	var other_type = other_thing.get_type()
	
	var ship_types = ["squadron", "carrier", "landfort"]
	var plane_types = ["scoutPlane", "fighter", "torpBomber", "levelBomber"]

	var is_ship_squad = other_type in ship_types
	var is_plane_squad = other_type in plane_types
	
	if is_ship_squad:
		self.set_enemy_squadron(other_thing)
	if is_plane_squad:
		self.take_plane_damage(other_thing)
	
	if self.faction != GameState.get_playerFaction():
		show()
	
func on_detection_left():
	if in_combat == true:
		self.exit_combat()
	
	if self.faction != GameState.get_playerFaction():
		
		hide()
		
func exit_combat():
	in_combat = false

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

func update_healthbar():
	get_node("HealthBar").value = get_total_health()
	
func shoot_guns(weapon_shooting_list, enemy_squadron, stopped=false):
	
	if enemy_squadron and weapon_shooting_list:

		for w in weapon_shooting_list:
			enemy_squadron.take_damage(w, global_position.distance_to(enemy_squadron.global_position), stopped)


func take_plane_damage(plane_squad):
	if plane_squad.get_faction() != self.get_faction():
		
		self.shoot_guns(self.get_weapon_list(), plane_squad)
		plane_squad.shoot_guns(plane_squad.get_weapon_list(), self)

func get_weapon_list():
	pass

func get_squad_info():
	# Name, HP, armor, speed, composition
	var squad_text = ""
	
	if len(task_force_name) > 0:
		squad_text += task_force_name + "\n"
	
	squad_text += "Speed: " + str(base_speed)

	return squad_text
