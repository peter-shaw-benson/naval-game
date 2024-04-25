extends Area2D

export var Bullet : PackedScene

# bullet data here
var weaponData: Weapon

var y_offset = 0
var x_offset = 0
var num_barrels = 1
var turn_weight = 0
var firing_arc = [0,0]

var locked = true

var target = Vector2(0,0)
var close_enemy
var faction: int
var fact_string = "faction_"
var faction_visibility_group = "visible_to_"

var aa_gun = false

func init(weapon, faction):
	# here, weapon is a dict of weapon data, y offset, and number of barrels
	self.weaponData = weapon["weapon"]
	
	#print(self.weaponData.get_name())
	
	self.y_offset = weapon["offset"][1]
	self.x_offset = weapon["offset"][0]
	
	#print(self.x_offset, self.y_offset)
	
	self.num_barrels = weapon["barrels"]
	self.turn_weight = weapon["turn_weight"]
	self.aa_gun = weaponData.is_aa_gun()
	
	self.firing_arc[0] = deg2rad(weapon["firing_arc"][0])
	self.firing_arc[1] = deg2rad(weapon["firing_arc"][1])
	
	# set sprite from the sprite path given in the weapon dict
	var frames = load(weapon["sprite_path"])
	get_node("AnimatedSprite").set_sprite_frames(frames)
	
	get_node("AnimatedSprite").animation = "default"
	
	#print(frames)
	#print(weapon["sprite_path"])
	
	#get_node("AnimatedSprite").speed_scale = 1
	
	self.position.y += self.y_offset
	self.position.x += self.x_offset
	
	self.faction = faction
	self.fact_string += str(faction)
	self.faction_visibility_group += str(faction)
	
	#print(self.faction_visibility_group)
	
func _ready():
	pass

func _process(delta):
	if not locked:

		var all_enemy = get_tree().get_nodes_in_group(faction_visibility_group)

		for enemy in all_enemy:
			var gun2enemy_distance = self.global_position.distance_to(enemy.global_position)
			#print(gun2enemy_distance)
			if gun2enemy_distance < self.weaponData.get_range() and enemy.get_faction() != self.faction:
				
				if enemy.is_plane() and not self.is_aa_gun():
					pass
				
				elif not enemy.is_plane() and self.is_aa_gun():
					pass
				
				else:

					close_enemy = enemy  ## --->## after get the current close_enemy

					# lerped (slowed down rotation)
					# need to use global rotation otherwise things get bad
					target = close_enemy.global_position

					self.global_rotation = lerp_angle(self.global_rotation, 
						(target - self.global_position).normalized().angle(), 
						self.turn_weight)
					
	# fuck. we have to handle the turret alignment here:
	
					
#	if not locked:
#		self.point_to(target)

#	self.rotation = clamp(self.rotation, firing_arc[0], firing_arc[1])

	pass

func align():
	return 0
					

func shoot():
	
	for b in self.num_barrels:
		# shoot one bullet per barrel
		var bullet = Bullet.instance()
		
		bullet.init(weaponData,
			self.global_position)
		
		get_tree().root.add_child(bullet)
		
		bullet.transform = $Barrel.global_transform
	
	#print("shooting")
	
	get_node("AnimatedSprite").animation = "shoot"
	get_node("AnimatedSprite").play()
	
	#get_node("AnimatedSprite").animation = "default"
	
	#if get_node("AnimatedSprite").animation == "default":
	#play_shoot_animation()

func play_shoot_animation():
	get_node("AnimatedSprite").animation = "shoot"
	get_node("AnimatedSprite").play()
	

func unlock():
	self.locked = false

func lock():
	self.locked = true
	
func set_target(new_target):
	self.target = new_target

func point_to(position):
	self.look_at(position)

func get_name():
	return self.weaponData.get_name()
	
func get_range():
	return self.weaponData.get_range()

func is_aa_gun():
	return self.aa_gun

func get_fire_rate():
	return self.weaponData.get_fire_rate()


func _on_AnimatedSprite_animation_finished():
	get_node("AnimatedSprite").animation = "default"
