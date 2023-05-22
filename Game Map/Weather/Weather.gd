extends Node
class_name Weather

var default_wind_dir_std = PI / 4
var default_wind_speed_std = 0.1
var wind_speed_max = 10

var current_speed_std = PI / 4
var current_wind_speed = 0

var current_dir_std = 0.1
var current_wind_direction = 0
var fog_list = []
var rng = RandomNumberGenerator.new()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#samples new wind directionfrom a normal distribution
func calc_new_wind_direction():
	var sampled_direction = rng.randfn(current_wind_direction, current_dir_std)
	
	#loops the angle if it goes above 2pi or under 0
	if sampled_direction > 2 * PI:
		sampled_direction = sampled_direction - (2 * PI)
	if sampled_direction < 0:
		sampled_direction = sampled_direction + (2 * PI)
	current_wind_direction = sampled_direction
	
#samples new wind_speed with normal distribution
func calc_new_wind_speed():
	var new_speed = rng.randfn(current_wind_speed, current_speed_std)
	#max speed check
	while abs(new_speed) > wind_speed_max:
		new_speed = rng.randfn(current_wind_speed, current_speed_std)
	
	if new_speed < 0:
		new_speed = abs(new_speed)
		current_wind_direction = current_wind_direction + PI
		
	current_wind_speed = new_speed
	
func get_wind_velocity_cartesian():
	return Vector2(current_wind_speed*cos(current_wind_direction), \
	current_wind_speed*sin(current_wind_direction))
# Called when the node enters the scene tree for the first time.

func get_fog_gen_flag():
	if rand_range(0, 1) < 0.2:
		return true
	return false
	
func update_fog():
	for fog in fog_list:
		fog.set_movement(get_wind_velocity_cartesian())

func register_fog(fog_in):
	fog_list.append(fog_in)

func get_wind_dir_angle():
	return current_wind_direction + 3*PI/2

func get_wind_speed_kt():
	return int(current_wind_speed * 10)

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
