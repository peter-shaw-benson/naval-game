extends Area2D

var speed: int
var max_range: int

var initial_pos = Vector2(0,0)

func init(speed, max_range, turret_pos):
	print("making bullet")
	self.speed = speed
	self.max_range = max_range
	
	initial_pos = turret_pos
	
	get_node("AnimatedSprite").animation = "shell"

func _physics_process(delta):
	position += transform.x * speed * delta
	
	# test if max range is reached

	
	if self.global_position.distance_to(self.initial_pos) >= self.max_range:
		print("reached max range")
		queue_free()


func _on_Bullet_area_entered(area):
	
	if self.global_position.distance_to(self.initial_pos) >= 30:
	
		print("bullet entered area")
		print(area.get_class())
		print(area.get_type())
	
		get_node("AnimatedSprite").animation = "explosion"
		get_node("AnimatedSprite").play()
		
		self.speed = 0
	
		if area.get_name() == "ShipScene":
			# deal damage here
			pass
	
		#queue_free()

# IDEAS:
# longer distance = less damage?
# damage = speed, speed goes down slightly over time 


func _on_AnimatedSprite_animation_finished():
	queue_free()
