extends CombatUnit
class_name ShipScene

func get_class(): return "ShipScene"

export var Turret: PackedScene
export var TorpedoTube: PackedScene

signal new_course_change(current_target, placement)
signal reached_target()
signal ship_lost()
signal hit(ship)

signal ship_selected(ship)
signal ship_deselected(ship)

var stopped = false
var patrolling = false
var target_array = []
var target_angle = {"turning": false, "turn_point": Vector2(0,0)}

# Combat stuff
var combat_entity
var combat_target
var faction_visibility_group = "visible_to_"
var in_combat = false
var combat_ticks = 0

# this is for placing the ghost sprite
var temp_target = Vector2(0,0)

# fire stuff
var burning_ships = []
# var ongoing_fire = Fire.new()
# ignore fire for now lol
var burning_animation = false

# repairing
var repairing = false

# speed, fuel
var speed_mode_dict = {
	"stopped": [0, 0],
	"half": [0.5, 0.2],
	"full": [1, 0.5],
	"flank": [1.5, 1]
}

var current_speed_mode

func _ready():
	
	add_to_group("ship")
	
	# add self to proper group (faction)
	if self.faction == 0:
		add_to_group("faction_0")
	elif self.faction == 1:
		add_to_group("faction_1")
	elif self.faction == 2:
		add_to_group("faction_2")
		
	self.faction_visibility_group += str(faction)
		
	if self.faction != GameState.get_playerFaction():
		add_to_group("enemy")
	else:
		add_to_group("player")
		
	# a ship should have three groups (flags): ship, faction, animosity
	
	# Combat Variables:
	get_node("ShotTimer").wait_time = GameState.get_combatPace()
	
	self.scale = Vector2(0.6, 0.6)
	
	screen_size = get_viewport_rect().size
	
	last_button = ""
	
	self.deselect()
	
	stop_moving()
	#print("stopped with the ready method, starting game.")
	
	# create turrets here:
	for w in self.get_weapon_list():
		var turret = Turret.instance()
		
		turret.init(w, self.faction)
		
		add_child(turret)
		
		turrets.append(turret)
	
	unlock_turrets()
	get_node("ShotTimer").start()
	
	# configure light
	get_node("DetectionLight")
	
func handle_right_click(placement):
	#print("handling right click")
	
	if selected and GameState.get_playerFaction() == get_faction():
		# this works properly for patrols:
		# print("last button:", last_button)
		#print("right clicked for course")
		# Turn logic is here for now?
		if Input.is_action_pressed("queue"):
			target_array.append(placement)
			
			emit_signal("new_course_change", current_target, placement)
			#print(target_array)
			
		elif last_button == "patrol":
			print("patrolling")
			patrolling = true
			current_target = placement
			target_array.append(self.global_position)
			
			print(target_array)
			print(current_target)
			print(self.global_position)
			print("patrolling value:", patrolling)
			
			emit_signal("new_course_change", current_target, placement)
			
			last_button = ""
			
			# need to start moving when you begin a patrol...
			if stopped:
				start_moving()
			
		else:
			patrolling = false
			target_array = []
			#print("stopped patrolling for some reason?")

			# unstops the ship, and also sets the current speed mode
			if stopped:
				start_moving()
				#end_repairs()
				
				# flank or half from stop
				if last_button == "flank" || last_button == "half":
					set_current_speed_mode(last_button)
					calc_current_speed()
	
				
			# handles setting a current target while already flanking 
			elif get_current_speed_mode() == "flank" || get_current_speed_mode() == "half":
				set_current_speed_mode(get_current_speed_mode())
			
			current_target = placement


func handle_final_turn(turn_point):
	self.target_angle["turning"] = true
	
	self.target_angle["turn_point"] = turn_point
	
	#print(self.target_angle)

func _input(event):
	if selected:
		if Input.is_action_pressed("stop"):
			set_current_speed_mode("stopped")
			calc_current_speed()
			self.current_target = self.global_position
			self.target_array = []
		
		elif Input.is_action_pressed("patrol"):
			last_button = "patrol"
			
		elif Input.is_action_pressed("flank speed"):
			last_button = "flank"
			
			# set speed to be higher here
			set_current_speed_mode("flank")
			calc_current_speed()
		
		elif Input.is_action_pressed("half speed"):
			last_button = "half"
			
			# set speed to be half here
			set_current_speed_mode("half")
			calc_current_speed()
		
		elif Input.is_action_pressed("full ahead"):
			last_button = "full"
			
			# set speed to be full here
			set_current_speed_mode("full")
			calc_current_speed()
			
		
		## COMBAT
		elif Input.is_action_just_pressed("shoot"):
			#print("shooting turrets")
			if selected and combat_enabled:
				self.shoot_turrets()
		
		
		elif Input.is_action_pressed("cancel"):
			last_button = ""

# change this (hardcode) for now.
# change arrow to the ship type later

func select():
	
	if self.is_in_group("player"):
		
		selected = true
		get_node("Sprite").animation = type + "_clicked"
		get_node("Sprite").set_frame(faction)
		
		#print(get_node("Sprite").animation)
		
		# yikes this might not hold up
		emit_signal("ship_selected", self)
		
		last_button = ""
		
		show_ghost_sprite()
		
func deselect():
	selected = false
	
	get_node("Sprite").animation = type + "_basic"
	get_node("Sprite").set_frame(faction)
	
	#print(get_node("Sprite").animation)
	
	emit_signal("ship_deselected", self)
	
	hide_ghost_sprite()

#func select():
#	print("selecting")
#
#	if faction == GameState.get_playerFaction():
#		selected = true
#		get_node("Sprite").animation = "arrow" + "_clicked"
#		get_node("Sprite").set_frame(faction)
#
#		print(get_node("Sprite").animation)
#
#		emit_signal("ship_selected", self)
#
#		last_button = ""
#
#func deselect():
#	print("deselecting")
#
#	selected = false
#
#	get_node("Sprite").animation = "arrow" + "_basic"
#	get_node("Sprite").set_frame(faction)
#
#	print(get_node("Sprite").animation)
#
#	emit_signal("ship_deselected", self)

# these are here for later, if we build ports n shit
#func start_repairs():
#	print("repairing")
#
#	self.current_target = self.global_position
#	self.target_array = []
#
#	stop_moving()
#
#	self.repairing = true
#	get_node("RepairClock").start()
#
#func end_repairs():
#	print("stopped repairing")
#
#	self.repairing = false
#	start_moving()
#
#	get_node("RepairClock").stop()
	
# movement functions:
# took out fuel indicators – idk how to do fuel with the new ships.
func start_moving():
	#print("started moving")
	
	stopped = false
	set_current_speed_mode("full")
	calc_current_speed()

func stop_moving():
	stopped = true
	set_current_speed_mode("stopped")

# Handle Island collisions
func _on_Squadron_area_entered(area):
	if area.get_faction() == 4:
		# Entered Hiding Area 
		hide()
		self.current_target = self.global_position
		self.target_array = []
		
		emit_signal("hit", self)
		
		get_node("IslandCollision").set_deferred("disabled", true)
	
	if area.get_faction() == 5:
		do_fog_effects()

func do_fog_effects():
	print("fog found")
	
func _physics_process(delta):
	
	if placing:
		# Place squadron at mouse, until the mouse clicks
		global_position = get_viewport().get_mouse_position()
		current_target = self.global_position
	
	else:
		
		var movement_vector = Vector2(0,0)
		#if distance to target is small and there are queued targets,
		#remove the target from the queue and update the current target
		
		
		#print("patrolling, target array:", target_array)
		if global_position.distance_to(current_target) < 10 and len(target_array) > 0:
			emit_signal("reached_target")
			
			if patrolling: 
				target_array.append(current_target)
				#print("patrolling, target array:", target_array)
			
			current_target = target_array[0]
			
			target_array.remove(0)
		
		#if we are close to the last target, set stopped to true
		elif global_position.distance_to(current_target) < 10:
			
			emit_signal("reached_target")
			
			stop_moving()

		if int(global_position.distance_to(current_target)) > 1 and not stopped:
			self.rotation = lerp_angle(self.rotation, (current_target - self.global_position).normalized().angle() + PI/2, self.turn_weight)

		if not stopped:
			self.calc_new_velocity()
			
			velocity_vector = move_and_slide(self.velocity_vector)
			
		elif self.target_angle["turning"]:
			var angle_to_turn_target = (target_angle["turn_point"] - self.global_position).normalized().angle() + PI/2
			
			self.global_rotation = lerp_angle(self.global_rotation, angle_to_turn_target, self.turn_weight)
			# recycling some code earlier – couldn't figure it out any other way
			
			if abs(angle_to_turn_target - self.global_rotation) <= 0.01:
				# if we reached the turn targe,t stope turning
				self.target_angle["turning"] = false
				self.target_angle["turn_point"] = self.global_position
	
	#position.x = clamp(position.x, 0, screen_size.x)
	#position.y = clamp(position.y, 0, screen_size.y)

func _process(delta):
	
	draw_ghost_sprite()
	
	align_turrets()
	
func set_firing_target(firing_target):
	
	# idk how to do this one yet
	self.firing_target = firing_target

# update this later, once turrets are added
func _on_ShotTimer_timeout():
	if is_instance_valid(combat_entity) and in_combat:
		self.shoot_ship_turrets(combat_ticks)
		
		self.combat_ticks += 1
		
func shoot_ship_turrets(combat_ticks):
	
	for t in turrets:

		if int(combat_ticks) % int(t.get_fire_rate()) == 0:
			
			if t.is_aa_gun() and combat_entity.is_plane():
				t.shoot()
			elif not t.is_aa_gun() and not combat_entity.is_plane():
				t.shoot()
	
# TODO: make a bullet deal damage.
func take_damage(weapon: Weapon):
	
	self.unitData.damage(weapon)
	
	if self.get_health() <= 0:
		print("ship lost")
		emit_signal("ship_lost", self)

# if / when we add back fuel, we can use the prototypes in the Ship Squadron class.

func set_current_speed_mode(speed_mode):
	current_speed_mode = speed_mode

func get_current_speed_mode():
	return current_speed_mode

func calc_current_speed():
	
	#if out_of_fuel():
		# this will automatically refuel the ship. 
		# the player will have to manually stop repairs to continue.
	#	start_repairs()

	current_speed = speed_mode_dict[current_speed_mode][0] * self.getSpeed()




## COMBAT
# this is unique to the ships – different for planes
# bugged for now 
func align_turrets():
	
	# we do this for each turret so they can independently target things.
	# change later?
	var valid_enemies = 0
	
	for t in turrets:
		var all_enemy = get_tree().get_nodes_in_group(faction_visibility_group)
		
		for enemy in all_enemy:
			var gun2enemy_distance = self.global_position.distance_to(enemy.global_position)
			
			#print(gun2enemy_distance)
			if gun2enemy_distance < t.weaponData.get_range() and \
				enemy.get_faction() != self.faction:
				# this is basically an XOR: the aa gun and plane have to match up
				if enemy.is_plane() and not t.is_aa_gun():
					pass
					
				else:
					combat_entity = enemy  ## --->## after get the current close_enemy
					
					# lerped (slowed down rotation)
					# need to use global rotation otherwise things get bad
					combat_target = combat_entity.global_position
					
					# t here is turret
					t.global_rotation = lerp_angle(t.global_rotation, 
						(combat_target - t.global_position).normalized().angle(), 
						t.turn_weight)
						
					valid_enemies += 1
				
	if self.in_combat == false and valid_enemies > 0:
		self.enter_combat()
	
	if valid_enemies == 0:
		self.exit_combat()
				

func enter_combat():
	self.in_combat = true
	
func exit_combat():
	self.in_combat = false


## Movement stuff
func draw_ghost_sprite():
	# here, we put the position of the ghost sprite over the mouse
	# then, if the right mouse is already being held down, 
	# we rotate the sprite so it's facing the right mouse
	
	var ghost_sprite = get_node("GhostSprite")
	
	# sets the alpha value to be very low
	ghost_sprite.self_modulate.a = 0.2
	
	ghost_sprite.global_position = get_global_mouse_position()
	
	if Input.is_action_pressed("right_click"):
		#print("rotating ghost sprite")
		# ideally, this should stick on the temp target
		ghost_sprite.global_position = self.temp_target
		ghost_sprite.look_at(get_global_mouse_position())
		ghost_sprite.rotation += PI/2
	
func hide_ghost_sprite():
	#print("hiding ghost sprite")
	get_node("GhostSprite").visible = false

func show_ghost_sprite():
	get_node("GhostSprite").visible = true

func set_temp_target(new_temp_target):
	self.temp_target = new_temp_target

func get_temp_target():
	return self.temp_target
