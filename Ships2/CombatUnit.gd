extends KinematicBody2D
class_name CombatUnit

var unitData: EntityJSON

export var detector_scene: PackedScene

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
	
	
var speed: int
var base_speed: int
var turn_speed: int
var turn_weight: float


# stopped, half, full ahead, flank
var speed_array = [0, speed / 2, speed, int(speed * 1.2)]


var visibility: float
var hiding: float
var detector: DetectionArea
var wind_resist: float

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
	var visibility_scale = visibility * GameState.get_visibility_scale()
	#var hiding_scale = hiding * 10
	
	detector = detector_scene.instance()
	detector.init(visibility_scale, self.faction)
	
	add_child(detector)
	
	self.current_speed = getSpeed()
	self.velocity_vector = Vector2(0, 0)
	
	self.position = initial_position

	self.rotation = self.initial_rot
	turn_speed = int(self.base_speed / 2)
	
	self.applied_wind = Vector2(0, 0)
	# Set max of health bar and Armor Bar
	
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
	


# SELECT / DESELCT
func select():
	pass

func deselect():
	pass


	
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






func enable_spotting():
	detector.enable_spotting()
		
func get_health():
	return self.unitData.get_health()

func get_armor():
	return self.unitData.get_armor()
	
	
	
	
	
	
## COMBAT
func align_turrets():
	
	pass
	
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

func _ready():
	pass
	
func enable_combat():
	self.combat_enabled = true

func disable_combat():
	self.combat_enabled = false

func is_plane():
	return false

# Detection:
func detect():
	self.show()
	
func un_detect():
	if self.faction != GameState.get_playerFaction():
		self.hide()

