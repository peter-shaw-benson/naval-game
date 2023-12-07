extends KinematicBody2D

const ScoutPlane = preload("res://Entities/Planes/ScoutPlane.gd")

signal plane_recovered(PlaneBoid)
signal plane_lost(PlaneBoid)

export var max_speed: = 100.0
export var mouse_follow_force: = 0.05
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

var parent_airbase_pos: Vector2
var current_target: Vector2

# plane characteristics
var plane_type: String
var plane_data: EntityJSON
var frames: SpriteFrames

var fuel_time = 8

func init(plane_type, airbase_pos, strike_target):
	self.strike_target = strike_target
	self.parent_airbase_pos = airbase_pos
	
	# the plane will always go towards its current target.
	self.current_target = strike_target
	
	# handles weaponry and such
	self.plane_type = plane_type
	
	if plane_type == "scout":
		self.plane_data = ScoutPlane.new()
		plane_data._init()
		
		var frames = load("res://art/Plane Sprites/ScoutPlaneSprite.tres")
		get_node("AnimatedSprite").set_sprite_frames(frames)
	
		get_node("AnimatedSprite").animation = "default"
		
		self.max_speed = self.plane_data.get_speed()
	
	get_node("FuelTimer").wait_time = fuel_time
	get_node("FuelTimer").start()
	

func initialize_plane_type(plane_type):
	
	if plane_type == "scout":
		self.plane_data = ScoutPlane.new()
		frames = load("res://art/Plane Sprites/ScoutPlaneSprite.tres")
	
	elif plane_type == "strike":
		self.plane_data = ScoutPlane.new()
		frames = load("res://art/Plane Sprites/ScoutPlaneSprite.tres")

	elif plane_type == "fighter":	
		self.plane_data = ScoutPlane.new()
		frames = load("res://art/Plane Sprites/ScoutPlaneSprite.tres")
	
	plane_data._init()
	
	get_node("AnimatedSprite").set_sprite_frames(frames)
	get_node("AnimatedSprite").animation = "default"
	
	self.max_speed = self.plane_data.get_speed()

func _ready():
	randomize()
	_velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * max_speed
	#_mouse_target = get_random_target()
	
	add_to_group("planes")


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
	
	var mouse_vector = Vector2.ZERO
	if current_target != Vector2.INF:
		mouse_vector = global_position.direction_to(current_target) * max_speed * mouse_follow_force
	
	# check if we have reached the strike target – if so, turn around
	# if we reach the airbase, start recovering?
	if global_position.distance_to(current_target) <= 20:
		if strike_target == current_target:
			current_target = parent_airbase_pos
		elif parent_airbase_pos == current_target:
			# recover plane here
			emit_signal("plane_recovered", self)
			
	
	# get cohesion, alginment, and separation vectors
	var vectors = get_flock_status(_flock)
	
	# steer towards vectors
	var cohesion_vector = vectors[0] * cohesion_force
	var align_vector = vectors[1] * algin_force
	var separation_vector = vectors[2] * separation_force

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
	current_target = parent_airbase_pos
	
