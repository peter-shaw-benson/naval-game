extends Area2D
class_name Island

func _ready():
	pass

func generate_new_island(map_center):
	
	var x_low = map_center.x - 400
	var x_high = map_center.x + 400
	var y_low = map_center.y - 200
	var y_high = map_center.y + 200
	
	# Position
	self.position.x = rand_range(x_low, x_high)
	self.position.y = rand_range(y_low, y_high)
	
	# Rotation
	self.rotation = rand_range(0, 2*PI)
	
	# Scale
	self.scale.x = rand_range(0.5, 1.5)
	self.scale.y = rand_range(0.5, 1.5)
	
	var island_drawing = self.get_node("AnimatedSprite")
	# Frame
	var frame_array = range(0,8)
	var frame_choice = frame_array[randi() % frame_array.size()]
	island_drawing.frame = frame_choice
	
	print("island:", self.position)
