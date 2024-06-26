extends Area2D
class_name Bullet

var speed: int
var max_range: int

var lifetime: float

var flakgun = false
var flak_exploded = false

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
		
		self.set_collision_mask_bit(3, true)
		self.set_collision_mask_bit(1, false)
		
	elif self.weaponData.get_name() == "machinegun":
		frames = preload("res://art/Bullets/MG/MGSprite.tres")
		get_node("AnimatedSprite").set_sprite_frames(frames)
		
		# make it so these only collide with planes
		self.set_collision_mask_bit(3, false)
		self.set_collision_mask_bit(1, true)

	elif self.weaponData.get_name() == "lightgun":
		# can hit boats, but not planes
		self.set_collision_mask_bit(3, true)
		self.set_collision_mask_bit(1, false)
		
	elif self.weaponData.get_name() == "flakgun":
		flakgun = true
		
		self.set_collision_mask_bit(3, false)
		self.set_collision_mask_bit(1, true)
		
	elif self.weaponData.get_name() == "flakbullet":
		
		frames = preload("res://art/Bullets/MG/MGSprite.tres")
		get_node("AnimatedSprite").set_sprite_frames(frames)
		
		self.set_collision_mask_bit(3, false)
		self.set_collision_mask_bit(1, true)

	get_node("AnimatedSprite").animation = "shell"

func _physics_process(delta):
	position += transform.x * speed * delta
	
	# test if max range is reached
	if self.global_position.distance_to(self.initial_pos) >= self.max_range:
		
		if flakgun and not flak_exploded:
			handle_flakgun()
			
		else:
			queue_free()


# IDEAS:
# longer distance = less damage?
# damage = speed, speed goes down slightly over time 


func _on_AnimatedSprite_animation_finished():

	queue_free()


func _on_Bullet_body_entered(body):
	
	if self.global_position.distance_to(self.initial_pos) >= 30:
	
		#print(body)
		
		if self.weaponData.get_name() == "torpedo":
			self.scale = Vector2(2, 2)
		
		get_node("AnimatedSprite").animation = "explosion"
		get_node("AnimatedSprite").play()
		
		self.speed = 0
	
		if body.is_in_group("ship"):
			var ship: CombatUnit = body
			
			ship.take_damage(self.weaponData)
		
		elif body.is_in_group("planes"):
			
			body.take_damage(self.weaponData)

func handle_flakgun():
	
	#self.speed = 0
	
	self.initial_pos = self.global_position
	self.max_range = 20
	self.rotation += ((randf() * 2) - 1)
	self.speed += 100
	
	flak_exploded = true
	
	#get_node("AnimatedSprite").animation = "shell"
	


func _on_fuseTimer_timeout():
	if self.weaponData.get_name() == "flak":
		# explode into multiple sub-bullets
		pass 
	queue_free()
