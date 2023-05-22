extends Area2D

var movement: Vector2
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func generate_fog_coords():
	var screen_size = get_viewport().size
	var random_coords = Vector2(rand_range(1, screen_size.x), rand_range(1, screen_size.y))
	return random_coords
	
func _physics_process(delta):
	global_position = global_position.move_toward(movement, delta*movement.length())
# Called when the node enters the scene tree for the first time.

func set_movement(movement_in: Vector2):
	self.movement = self.global_position + movement_in.rotated(3*PI/2)
	
func _ready():
	set_movement(Vector2(0, 0))
	self.global_position = generate_fog_coords()

func get_faction():
	return 5


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
