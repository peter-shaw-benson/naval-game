extends Area2D

export var Bullet : PackedScene

# bullet data here
var weaponData: Weapon

var y_offset = 0
var x_offset = 0
var num_barrels = 1
var turn_weight = 0

var locked = true

var target = Vector2(0,0)
var close_enemy

func init(weapon):
	# here, weapon is a dict of weapon data, y offset, and number of barrels
	self.weaponData = weapon["weapon"]
	
	self.y_offset = weapon["offset"][1]
	self.x_offset = weapon["offset"][0]
	self.num_barrels = weapon["barrels"]
	self.turn_weight = weapon["turn_weight"]
	
	# set sprite from the sprite path given in the weapon dict
	var frames = load(weapon["sprite_path"])
	get_node("AnimatedSprite").set_sprite_frames(frames)
	
	get_node("AnimatedSprite").animation = "default"
	
	#get_node("AnimatedSprite").speed_scale = 1
	
	self.position.y += self.y_offset
	
func _ready():
	pass

func _process(delta):
	# fuck. we have to handle the turret alignment here:
	
	if not locked:
		
		var all_enemy = get_tree().get_nodes_in_group("enemy")
		
		for enemy in all_enemy:
			var gun2enemy_distance = self.global_position.distance_to(enemy.global_position)
			#print(gun2enemy_distance)
			if gun2enemy_distance < self.weaponData.get_range() and enemy.visible:
				
				close_enemy = enemy  ## --->## after get the current close_enemy
				
				# lerped (slowed down rotation)
				# need to use global rotation otherwise things get bad
				target = close_enemy.global_position
				
				self.global_rotation = lerp_angle(self.global_rotation, 
					(target - self.global_position).normalized().angle(), 
					self.turn_weight)
					

func shoot():
	
	for b in self.num_barrels:
		# shoot one bullet per barrel
		var bullet = Bullet.instance()
		
		bullet.init(weaponData,
			self.global_position)
		
		get_tree().root.add_child(bullet)
		
		bullet.transform = $Barrel.global_transform
		
	get_node("AnimatedSprite").animation = "shoot"
	get_node("AnimatedSprite").play()
	
	get_node("AnimatedSprite").animation = "default"
	
	#if get_node("AnimatedSprite").animation == "default":
	#play_shoot_animation()

func play_shoot_animation():
	get_node("AnimatedSprite").animation = "shoot"
	get_node("AnimatedSprite").play()
	
	get_node("AnimatedSprite").animation = "default"

func unlock():
	self.locked = false

func lock():
	self.locked = true
	
func set_target(new_target):
	self.target = new_target

func point_to(position):
	self.look_at(position)
