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
		
var ships: Array
var speed: int

func _init():
	ships = [Ship.new(30)]
	speed = get_min_speed()
	print("squad created " + str(speed))
	
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

# Called when the node enters the scene tree for the first time.
func _ready():
	self.rotation = initial_rot
	print(self.rotation)
	screen_size = get_viewport_rect().size
	
	current_target = self.global_position

func _process(delta):
	if global_position.distance_to(current_target) < 10 and len(target_array) > 0:
		print("updating current target")
		emit_signal("reached_target")
		
		current_target = target_array[0]
		
		var angle = current_target.angle_to_point(position) + (PI / 2)
		self.rotation = angle
		
		target_array.remove(0)
	
	position = position.move_toward(current_target, delta*speed)
	
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

func _on_Map_right_click(placement):
	if selected:
		# Turn logic is here for now?
		if Input.is_action_pressed("queue"):
			target_array.append(placement)
			
			emit_signal("new_course_change", current_target, placement)
			print(target_array)
		else:
			var angle = placement.angle_to_point(position) + (PI / 2)
			current_target = placement
			
			self.rotation = angle
		

