class_name Squadron
extends Area2D

signal new_course_change(current_target, placement)
signal reached_target()

func get_min_speed():
	
	if len(ships) == 0:
		return 0
	else:
		var min_speed = ships[0].get_speed()
		
		for ship in ships:
			if ship.get_speed() < min_speed:
				min_speed = ship.get_speed()
		
		return min_speed

func get_min_turn():
	
	if len(ships) == 0:
		return 0
	else:
		var min_speed = ships[0].get_turn_rate()
		
		for ship in ships:
			if ship.get_turn_rate() < min_speed:
				min_speed = ship.get_turn_rate()
		
		return min_speed
		
var ships: Array
var speed: int
var turn_rate: int
var base_speed: int
var turn_speed: int

func _init():
	ships = [Ship.new(30, 2)]
	base_speed = get_min_speed()
	turn_rate = get_min_turn()
	
	# stopped, half, full ahead, flank
	var speed_array = [0, speed / 2, speed, int(speed * 1.2)]
	
	print("squad created")
	
func select():
	selected = true
	$Sprite.animation = "clicked"

func deselect():
	selected = false
	$Sprite.animation = "default"

func on_click():
	
	if selected:
		self.deselect()
	else:
		self.select()

func get_current_target():
	return current_target

var target_array = []

var current_target = Vector2()
var velocity = Vector2()
var selected = false
var initial_rot = 0
var screen_size
var current_speed
var turning = false


# Called when the node enters the scene tree for the first time.
func _ready():
	self.rotation = initial_rot
	print(self.rotation)
	screen_size = get_viewport_rect().size
	
	current_target = self.global_position
	current_speed = self.base_speed
	turn_speed = int(self.base_speed / 2)

func smooth_rotate():
	# start rotation when a few pixels away from target
	
	# slow speed during rotation, using move and slide
	
	# end of rotation: 
	pass

var weight = 0.1

func _process(delta):
	
	if global_position.distance_to(current_target) < (turn_speed * 2) and len(target_array) > 0:
		#print("updating current target")
		emit_signal("reached_target")
		
		current_target = target_array[0]
		#print(current_target)
		
		target_array.remove(0)
		
		# Turn here
		turning = true
		
		var angle_degrees = rad2deg(transform.x.angle_to(current_target))
		print(angle_degrees)
		
		if abs(angle_degrees) < 30:
			#print("stopped turning")
			self.rotation_degrees = rad2deg(global_position.angle_to_point(current_target) - PI/2)
			turning = false
			print("don't need to turn")
	
	if turning:
		#print(transform.x)
		var angle_degrees = rad2deg(transform.x.angle_to(current_target))
		#print(angle_degrees)
		
		if abs(angle_degrees) < 10:
			#print("stopped turning")
			self.rotation_degrees = rad2deg(global_position.angle_to_point(current_target) - PI/2)
			turning = false
		elif angle_degrees > 0:
			self.rotation_degrees += self.turn_rate
		elif angle_degrees < 0:
			self.rotation_degrees -= self.turn_rate
		
		position += transform.x * turn_speed * delta
		
	else:
		position = position.move_toward(current_target, delta * current_speed)
	
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
		# Turn logic is here for now?
		if Input.is_action_pressed("queue"):
			target_array.append(placement)
			
			emit_signal("new_course_change", current_target, placement)
			#print(target_array)
		else:
			var angle = placement.angle_to_point(position) + (PI / 2)
			current_target = placement
			
			self.rotation = angle
		

