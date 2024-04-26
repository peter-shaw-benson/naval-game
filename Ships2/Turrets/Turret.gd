extends Area2D

export var Bullet : PackedScene

# bullet data here
var weaponData: Weapon

var y_offset = 0
var x_offset = 0
var num_barrels = 1
var turn_weight = 0
var firing_arc = [0,0]
var default_rotation = 0

var local_rotation_target = 0

var locked = true

var target = Vector2(0,0)
var close_enemy
var in_weapons_range = false
var pointing_at_enemy = false
var close_enemy_distance

var faction: int
var fact_string = "faction_"
var faction_visibility_group = "visible_to_"

var aa_gun = false
# plane gun not being used rn
var plane_gun = false
var bullet_spread = 0
var shot_count = 0

var spread_rng

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
	self.bullet_spread = weaponData.get_spread()
	
	self.spread_rng = RandomNumberGenerator.new()
	spread_rng.seed = hash(get_instance_id())
	
	
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
	
	self.close_enemy_distance = self.weaponData.get_range() + 1
	
	self.faction = faction
	self.fact_string += str(faction)
	self.faction_visibility_group += str(faction)
	
	# set initial rotation
	self.default_rotation = (self.firing_arc[0] + self.firing_arc[1]) / 2
	self.rotation = default_rotation
#
	#print(self.faction_visibility_group)
	
func _ready():
	pass

func _process(delta):
	check_close_enemy()
	
	#target = get_global_mouse_position()

	if not locked:
		self.global_rotation = (target - self.global_position).normalized().angle()
#
	#self.rotation = clamp(self.rotation, firing_arc[0], firing_arc[1]) 
	var old_rotation = self.rotation
	
	self.rotation = turret_clamp(self.rotation, firing_arc[0], firing_arc[1])
	
	if old_rotation == self.rotation:
		pointing_at_enemy = true
	else:
		pointing_at_enemy = false
	#print(self.rotation)
	
	#if firing_arc[]

	pass
	
func turret_clamp(rot, angle_1, angle_2):
	# CASE 1: 
	# angle_1 = 0; angle_2 = 180. 
	# this is the back gun. 
	# if the rotation < 180 and > 0, we're good.
	
	# CASE 2: 
	# angle_1 = -180; angle_2 = 0.
	# front gun
	# if the rotation > -180 and < 0, we're good.
	
	# CASE 3:
	# angle_1 = -90; angle_2 = 90.
	# right gun
	# if the rotation > -90 and < 90, we're good.
	
	# CASE 4:
	# angle_1 = 90; angle_2 = 270.
	# left gun
	# if the rotation is negative, it must be less than -90. 
	# if the rotation is positive, it must be greater than 90. 
	
	# CASE 5:
	# angle_1 = -30; angle_2 = 210.
	# wide back gun
	# if the rotation is negative, must be more than -30 OR less than -150
	# if the rotation is positive, it must be between 0 and 180. 
	
	# CASE 6:
	# angle_1 = -210; angle_2 = 30.
	# wide front gun
	# if the rotation is negative, we're good. 
	# if the rotation is positive, it must be less than 30 or greater than 150
	
	
	var new_rot = (angle_1 + angle_2) / 2
	
	#print(angle_1, "\t", angle_2)
	#print(abs(angle_1), "\t", abs(angle_2))
	
	if (abs(angle_1) <= PI) and (abs(angle_2) <= PI):

		return clamp(rot, angle_1, angle_2)
	
	elif abs(angle_1) >= PI:
		var offset_angle_1 = PI - fmod(abs(angle_1), PI) 
		
		#print(rad2deg(rot), "\t", rad2deg(angle_1), "\t", rad2deg(angle_2), "\t", rad2deg(offset_angle_1))
		
		if rot > offset_angle_1 or rot < angle_2:
			return rot
		else:
			return new_rot
		
	elif abs(angle_2) >= PI:
		#print("offsetting angle")
		
		var offset_angle_2 = fmod(angle_2, PI) - PI
		
		#print(rad2deg(rot), "\t", rad2deg(angle_1), "\t", rad2deg(angle_2), "\t", rad2deg(offset_angle_2))
		
		if rot > angle_1 or rot < offset_angle_2:
			return rot
		else:
			return new_rot
	
	
func check_close_enemy():
	
#	if is_instance_valid(close_enemy) and close_enemy.is_in_group(faction_visibility_group):
#
#		target = close_enemy.global_position
#		#print(self.fact_string, close_enemy)
#
#	else:
	#if not locked:

	var all_enemy = get_tree().get_nodes_in_group(faction_visibility_group)
	
	close_enemy_distance = INF

	for enemy in all_enemy:
		# TODO: change this so it instead finds the _closest_ enemy, not just any enemy within weapons range.
		
		var gun2enemy_distance = self.global_position.distance_to(enemy.global_position)
		#print(gun2enemy_distance)
		if gun2enemy_distance < close_enemy_distance and enemy.get_faction() != self.faction:
				
			if (enemy.is_plane() and self.is_aa_gun()) or \
			(not enemy.is_plane() and not self.is_aa_gun()):
					
				#if enemy.is_plane() and self.is_aa_gun():

					#print("AA Gun firing at plane\t", gun2enemy_distance)
					
				in_weapons_range = true
					
				close_enemy_distance = gun2enemy_distance
			
				#print("found enemy; self faction: ", self.faction, " enemy faction: ", enemy.get_faction())

				close_enemy = enemy  ## --->## after get the current close_enemy

				# lerped (slowed down rotation)
				# need to use global rotation otherwise things get bad
				target = close_enemy.global_position
#
			# for some reason, for only the enemy ships, they end up getting here and "unfinding" the close enemy
#				else:
#					close_enemy = null

	if close_enemy_distance > weaponData.get_range() and in_weapons_range:
		
		in_weapons_range = false
		
		shot_count = 0
		
			# print("stopped firing")

func align():
	
	#print(self.faction, "\t", close_enemy)
	if in_weapons_range:
		return 1
	
	else:
		return 0
					

func shoot():
	
#	if (in_weapons_range and pointing_at_enemy) or \
#		(in_weapons_range and locked):
		
		if weaponData.get_name() == "flakgun":
			num_barrels = (int(randf() * 5) + 3)
			
		var accuracy_improvement = (-1) * shot_count * weaponData.get_accuracy_gain()
		# current accuracy = bullet_spread * accuracyGainFactor ^ (shot_count * accuracy gain)
		
		var new_spread = self.bullet_spread * pow(GameState.get_accuracy_growth_factor(), accuracy_improvement)
		
		if new_spread <= 0:
			new_spread = 0.01
		
		# add bullet spread
		var this_bullet_spread = spread_rng.randf_range(-1 * new_spread, new_spread)
		
		for b in self.num_barrels:
			# shoot one bullet per barrel
			var bullet = Bullet.instance()

			bullet.init(weaponData,
				self.global_position)

			get_tree().root.add_child(bullet)

			bullet.transform = $Barrel.global_transform
			#print(this_bullet_spread)
			
			bullet.rotation += this_bullet_spread
			
		shot_count += 1
		
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
