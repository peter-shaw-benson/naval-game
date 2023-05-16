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
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func init(unit_array, initial_position, faction, type):
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
	self.wind_resist = get_squad_wind_resist()
	
	
	# Set up Visibility Collider and Hiding Collider
	var visibility_scale = visibility * 5
	#var hiding_scale = hiding * 10
	
	detector = detector_scene.instance()
	detector.init(visibility_scale)
	
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

#creates new velocity vector with applied wind
func calc_new_velocity():
	var unit_velocity_cartesian = Vector2(current_speed * cos(global_rotation), current_speed * sin(global_rotation))
	self.velocity_vector = unit_velocity_cartesian + 100 * applied_wind

#calculates the wind vector on wind change
func calc_new_wind_vector(wind_cartesian):
	applied_wind = (1 - wind_resist) * wind_cartesian
	
	
func get_units():
	return self.units

func get_type():
	return self.type

func select():
	if faction == GameState.get_playerFaction():
		selected = true
		$Sprite.animation = sprite_type + "_clicked"
		$Sprite.set_frame(faction)
		
		emit_signal("squad_selected", self)
		
func deselect():
	selected = false
	$Sprite.animation = sprite_type + "_basic"
	$Sprite.set_frame(faction)
	
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
	and event.button_index == 1 \
	and event.pressed:
		if self.selected:
			self.deselect()
		
		if self.placing:
			self.stop_placing()

func start_placing():
	placing = true
	
	global_position = get_viewport().get_mouse_position()
	
	get_node("IslandCollision").disabled = true
	
func stop_placing():
	placing = false

	emit_signal("stopped_placing")
	
	get_node("IslandCollision").disabled = false
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
	#print("found other thing:")
	#print(other_thing.get_name())
	#print("Squadron" in other_thing.get_name())
	
	# this is a REALLY BAD way to do it – 
	# the plane squad name is PlaneSquad, not PlaneSquadron
	var other_name = other_thing.get_name()
	var is_ship_squad = ("ron" in other_name) or ("Carrier" in other_name)
	var is_plane_squad = "Plane" in other_name
	
	# Not gonna work for plane squadrons
	#print(other_thing.get_type())
	if is_ship_squad:
		#print("ships detected, entering combat")
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

func update_armorbar():
	get_node("ArmorBar").value = get_total_armor()
	
func shoot_guns(weapon_shooting_list, enemy_squadron):
	
	if enemy_squadron and weapon_shooting_list:
		#print(len(weapon_shooting_list))
		for w in weapon_shooting_list:
			enemy_squadron.take_damage(w, global_position.distance_to(enemy_squadron.global_position))
			enemy_squadron.update_armorbar()
			enemy_squadron.update_healthbar()

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
	
	squad_text += "Health: " + str(get_total_health()) + " Armor: " + str(get_total_armor()) + " Speed: " + str(base_speed)

	return squad_text
