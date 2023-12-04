extends Area2D
class_name Bullet

var speed: int
var max_range: int

var weaponData: Weapon

var initial_pos = Vector2(0,0)

func init(weaponData, turret_pos):
	self.weaponData = weaponData
	
	self.speed = self.weaponData.get_speed()
	self.max_range = self.weaponData.get_range()
	
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
	
		get_node("AnimatedSprite").animation = "explosion"
		get_node("AnimatedSprite").play()
		
		self.speed = 0
	
		if area.get_class() == "ShipScene":
			var ship: ShipScene = area
			
			ship.take_damage(self.weaponData)
	
		#queue_free()

# IDEAS:
# longer distance = less damage?
# damage = speed, speed goes down slightly over time 


func _on_AnimatedSprite_animation_finished():
	queue_free()
