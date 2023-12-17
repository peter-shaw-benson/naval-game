extends KinematicBody2D

const ScoutPlane = preload("res://Entities/Planes/ScoutPlane.gd")
const Fighter = preload("res://Entities/Planes/Fighter.gd")
const TorpBomber = preload("res://Entities/Planes/TorpBomber.gd")

export var detector_scene: PackedScene
export var Turret: PackedScene

signal plane_recovered(PlaneBoid)
signal plane_lost(PlaneBoid)

export var max_speed: = 100.0
export var mouse_follow_force: = 0.05

# Cohesion = how tight the groups are
# alignment = ?
# separation = how far apart for the groups
# fighters should have high cohesion, high separation
# strike aircraft should have medium cohesion, low separation
# scouts should have low cohesion, high separation (but doesn't matter a ton)
export var cohesion_force: = 0.05
export var algin_force: = 0.05
export var separation_force: = 0.05

export(float) var view_distance: = 50.0
export(float) var avoid_distance: = 20.0


var _width = ProjectSettings.get_setting("display/window/size/width")
var _height = ProjectSettings.get_setting("display/window/size/height")

var _flock: Array = []
var strike_target: Vector2
var _velocity: Vector2

var parent_airbase: CombatUnit

var current_target: Vector2
var returning = false

# plane characteristics
var plane_type: String
var plane_data: CombatPlane
var frames: SpriteFrames

var faction: int

var fuel_time = 8

var detector: DetectionArea
var visibility

## COMBAT:
var turrets: Array
# all turrets face forward
var close_enemy
var combat_target
var target_lock = false

# planes have one main weapon
var main_weapon
var main_weapon_ammo: int
var main_weapon_range: int

func init(plane_type, airbase, strike_target, faction):
	self.strike_target = strike_target
	
	self.parent_airbase = airbase
	
	# the plane will always go towards its current target.
	self.current_target = strike_target
	#print(self.current_target)
	
	# handles weaponry and such
	self.plane_type = plane_type
	
	self.faction = faction
	
	self.initialize_plane_type(plane_type)
	
	self.cohesion_force = self.plane_data.get_cohesion()
	self.separation_force = self.plane_data.get_separation()
	
	self.fuel_time = self.plane_data.get_fuel()
	
	get_node("FuelTimer").wait_time = fuel_time
	get_node("FuelTimer").start()
	
	
	visibility = self.plane_data.get_visibility()
	
	# Set up Visibility Collider and Hiding Collider
	var visibility_scale = visibility * GameState.get_visibility_scale()

	
	# set up detection
	detector = detector_scene.instance()
	detector.init(visibility_scale, self.faction)
	
	add_child(detector)
	detector.enable_spotting()
	

func initialize_plane_type(plane_type):
	
	if plane_type == "scout":
		self.plane_data = ScoutPlane.new()
		frames = load("res://art/Plane Sprites/ScoutPlaneSprite.tres")
	
	elif plane_type == "strike":
		self.plane_data = TorpBomber.new()
		frames = load("res://art/Plane Sprites/StrikePlaneSprite.tres")

	elif plane_type == "fighter":	
		self.plane_data = Fighter.new()
		frames = load("res://art/Plane Sprites/FighterPlaneSprite.tres")
	
	plane_data._init()
	
	get_node("AnimatedSprite").set_sprite_frames(frames)
	get_node("AnimatedSprite").animation = "default"
	
	self.max_speed = self.plane_data.get_speed()
	
	self.scale = Vector2(0.6, 0.6)
	
	# make turrets
	for w in self.plane_data.get_weapons():
		var turret = Turret.instance()
		
		turret.init(w, faction)
		
		add_child(turret)
		
		turrets.append(turret)
		
		turret.rotation = -1 * PI/2
		turret.lock()
		
		if turret.get_name() != "machinegun":
			main_weapon = turret
			
			main_weapon_ammo = w["ammo"]
			
			main_weapon_range = main_weapon.get_range()
		
		#turret.visible = false

func _ready():
	randomize()
	_velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * max_speed
	#_mouse_target = get_random_target()
	
	#print(_velocity)
	
	add_to_group("planes")
	
	if self.faction == 0:
		add_to_group("faction_0")
	elif self.faction == 1:
		add_to_group("faction_1")
	elif self.faction == 2:
		add_to_group("faction_2")


func _on_detection_radius_body_entered(body: PhysicsBody2D):
	if self != body and body.is_in_group("planes"):
		_flock.append(body)


func _on_detection_radius_body_exited(body: PhysicsBody2D):
	if body in _flock:
		_flock.remove(_flock.find(body))


func _input(event):
	pass


func _physics_process(_delta):
	# if it reaches the 
	check_parent_airbase()
	check_enemy_pos()
	
	if self.main_weapon_ammo > 0:
		# this is AWFUL for performance. move into a flock next? or have a timer to check?
		find_enemy_ship()
	
	var mouse_vector = Vector2.ZERO
	if current_target != Vector2.INF:
		mouse_vector = global_position.direction_to(current_target) * max_speed * mouse_follow_force
	
	# check if we have reached the strike target – if so, turn around
	# if we reach the airbase, start recovering?
	if global_position.distance_to(current_target) <= 25:
		if strike_target == current_target and target_lock:
			self.shoot()
			
		elif strike_target == current_target:
			self.go_home()
			
		elif self.returning:
			emit_signal("plane_recovered", self)
			
			
	
	# get cohesion, alginment, and separation vectors
	var vectors = get_flock_status(_flock)
	
	# steer towards vectors
	var cohesion_vector = vectors[0] * self.cohesion_force
	var align_vector = vectors[1] * self.algin_force
	var separation_vector = vectors[2] * self.separation_force

	var acceleration = cohesion_vector + align_vector + separation_vector + mouse_vector
	
	_velocity = (_velocity + acceleration).clamped(max_speed)
	
	_velocity = move_and_slide(_velocity)
	
	# this looks in the same direction as its movement
	global_rotation = _velocity.angle() + PI/2


func get_flock_status(flock: Array):
	var center_vector: = Vector2()
	var flock_center: = Vector2()
	var align_vector: = Vector2()
	var avoid_vector: = Vector2()
	
	for f in flock:
		var neighbor_pos: Vector2 = f.global_position

		align_vector += f._velocity
		flock_center += neighbor_pos

		var d = global_position.distance_to(neighbor_pos)
		if d > 0 and d < avoid_distance:
			avoid_vector -= (neighbor_pos - global_position).normalized() * (avoid_distance / d * max_speed)
	
	var flock_size = flock.size()
	if flock_size:
		align_vector /= flock_size
		flock_center /= flock_size

		var center_dir = global_position.direction_to(flock_center)
		var center_speed = max_speed * (global_position.distance_to(flock_center) / $detection_radius/ViewRadius.shape.radius)
		center_vector = center_dir * center_speed

	return [center_vector, align_vector, avoid_vector]


func get_random_target():
	randomize()
	return Vector2(rand_range(0, _width), rand_range(0, _height))

func get_plane_type():
	return self.plane_type

func _on_FuelTimer_timeout():
	#print("plane out of fuel")
	check_parent_airbase()
	
	self.returning = true
	
	self.cohesion_force = 0.05
	self.algin_force = 0.05
	self.separation_force = 0.05
	
func detect():
	self.show()
	
func un_detect():
	if self.faction != GameState.get_playerFaction():
		self.hide()

func go_home():
	check_parent_airbase()
		
	self.returning = true
	
	self.cohesion_force = 0.05
	self.algin_force = 0.05
	self.separation_force = 0.05
	
	target_lock = false

func check_parent_airbase():
	if returning:
		if is_instance_valid(self.parent_airbase):
			current_target = self.parent_airbase.global_position
		else:
			queue_free()

func check_enemy_pos():
	if target_lock:
		if is_instance_valid(close_enemy):
			strike_target = close_enemy.global_position
			current_target = strike_target
		else:
			target_lock = false
			close_enemy = null


## COMBAT!!!
func take_damage(weapon):
	#print("damaged plane")
	
	self.plane_data.damage(weapon)
	#print(weapon.get_name())
	
	if self.get_health() <= 0:
		print("plane lost")
		queue_free()

func get_health():
	return self.plane_data.get_health()


## Shooting logic:
func shoot():
	if main_weapon_ammo > 0 and target_lock:
		main_weapon.shoot()
		main_weapon_ammo -= 1
		
	if main_weapon_ammo <= 0:
		self.go_home()
		

func find_enemy_ship():
	var all_enemy = get_tree().get_nodes_in_group("enemy")
	
	var closest_distance = 10000
	
	
	for enemy in all_enemy:
		var enemy_distance = self.global_position.distance_to(enemy.global_position)
		#print(gun2enemy_distance)
		
		if enemy.visible and enemy_distance < closest_distance:
			
			close_enemy = enemy
			
			strike_target = close_enemy.global_position
			current_target = strike_target
			
			target_lock = true
			# find the closest visible enemy
			# set the new strike target to them
			# if they're in main weapon range, fire the main weapon
			
			if enemy_distance < main_weapon_range:
				self.shoot()
			
	pass

func is_plane():
	return true

func get_faction():
	return self.faction
