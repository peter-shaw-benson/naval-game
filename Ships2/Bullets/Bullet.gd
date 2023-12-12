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
	var frames
	
	if self.weaponData.get_name() == "torpedo":
		# we use preload because it would be way faster than doing this for all bullets at runtime with "load"
		frames = preload("res://art/Bullets/Torpedo/TorpedoFrames.tres")
		get_node("AnimatedSprite").set_sprite_frames(frames)
		
		self.set_collision_mask_bit(4, true)
		self.set_collision_mask_bit(2, false)
		
	if self.weaponData.get_name() == "machinegun":
		frames = preload("res://art/Bullets/MG/MGSprite.tres")
		get_node("AnimatedSprite").set_sprite_frames(frames)
		
		# make it so these only collide with planes
		self.set_collision_mask_bit(3, true)
		self.set_collision_mask_bit(1, true)

	elif self.weaponData.get_name() == "lightgun":
		
		self.set_collision_mask_bit(3, true)
		self.set_collision_mask_bit(1, false)

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
	
		#print(body)
			
		get_node("AnimatedSprite").animation = "explosion"
		get_node("AnimatedSprite").play()
		
		self.speed = 0
	
		if body.is_in_group("ship"):
			var ship: CombatUnit = body
			
			ship.take_damage(self.weaponData)
		
		elif body.is_in_group("planes"):
			
			body.take_damage(self.weaponData)
