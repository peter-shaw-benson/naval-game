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
	
	# set sprite frames here
	if self.weaponData.get_name() == "torpedo":
		var frames = preload("res://art/Bullets/Torpedo/TorpedoFrames.tres")
		get_node("AnimatedSprite").set_sprite_frames(frames)
	
	get_node("AnimatedSprite").animation = "shell"

func _physics_process(delta):
	position += transform.x * speed * delta
	
	# test if max range is reached
	if self.global_position.distance_to(self.initial_pos) >= self.max_range:
		queue_free()


# IDEAS:
# longer distance = less damage?
# damage = speed, speed goes down slightly over time 


func _on_AnimatedSprite_animation_finished():
	queue_free()


func _on_Bullet_body_entered(body):
	if self.global_position.distance_to(self.initial_pos) >= 30:
	
		get_node("AnimatedSprite").animation = "explosion"
		get_node("AnimatedSprite").play()
		
		self.speed = 0
	
		if body.is_in_group("ship"):
			var ship: ShipScene = body
			
			ship.take_damage(self.weaponData)
