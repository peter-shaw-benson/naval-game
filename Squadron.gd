class_name Squadron
extends Area2D

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

var target = Vector2()
var velocity = Vector2()
var selected = false
var initial_rot = 0
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	self.rotation = initial_rot
	print(self.rotation)
	screen_size = get_viewport_rect().size
	
	target = self.global_position

func _process(delta):
	position = position.move_toward(target, delta*speed)
	
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
		var angle = placement.angle_to_point(position) + (PI / 2)
		target = placement
		
		self.rotation = angle

