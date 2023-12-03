extends CombatUnit
class_name ShipScene

signal new_course_change(current_target, placement)
signal reached_target()
signal ship_lost()
signal hit(ship)

var stopped = false
var patrolling = false
var target_array = []

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
	
	# Combat Variables:
	get_node("ShotTimer").wait_time = GameState.get_combatPace()
	
	self.scale = Vector2(0.6, 0.6)
	
	screen_size = get_viewport_rect().size
	
	last_button = ""
	
	# Make sure it doesn't crash until we're done placing
	get_node("IslandCollision").disabled = true
	
	self.deselect()
	
	stop_moving()
	print("stopped with the ready method, starting game.")
	
func handle_right_click(placement):
	if selected and GameState.get_playerFaction() == get_faction():
		#print("right clicked for course")
		# Turn logic is here for now?
		if Input.is_action_pressed("queue"):
			target_array.append(placement)
			
			emit_signal("new_course_change", current_target, placement)
			#print(target_array)
			
		elif last_button == "patrol":
			patrolling = true
			current_target = placement
			target_array.append(self.global_position)
			
			emit_signal("new_course_change", current_target, placement)
			
			last_button = ""
			
		else:
			patrolling = false
			target_array = []

			# unstops the ship, and also sets the current speed mode
			if stopped:
				start_moving()
				end_repairs()
				
				# flank or half from stop
				if last_button == "flank" || last_button == "half":
					set_current_speed_mode(last_button)
					calc_current_speed()
	
				
			# handles setting a current target while already flanking 
			elif get_current_speed_mode() == "flank" || get_current_speed_mode() == "half":
				set_current_speed_mode(get_current_speed_mode())
			
			current_target = placement

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
		
		elif Input.is_action_pressed("cancel"):
			last_button = ""

# change this (hardcode) for now.
# change arrow to the ship type later
func select():
	print("selecting")
	
	if faction == GameState.get_playerFaction():
		selected = true
		get_node("Sprite").animation = "arrow" + "_clicked"
		get_node("Sprite").set_frame(faction)
		
		print(get_node("Sprite").animation)
		
		emit_signal("ship_selected", self)
		
		last_button = ""
		
func deselect():
	print("deselecting")
	
	selected = false
	
	get_node("Sprite").animation = "arrow" + "_basic"
	get_node("Sprite").set_frame(faction)
	
	print(get_node("Sprite").animation)
	
	emit_signal("ship_deselected", self)

# these are here for later, if we build ports n shit
func start_repairs():
	print("repairing")
	
	self.current_target = self.global_position
	self.target_array = []
	
	stop_moving()
			
	self.repairing = true
	get_node("RepairClock").start()
	
func end_repairs():
	print("stopped repairing")
	
	self.repairing = false
	start_moving()
	
	get_node("RepairClock").stop()
	
# movement functions:
# took out fuel indicators – idk how to do fuel with the new ships.
func start_moving():
	print("started moving")
	
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
		#if distance to target is small and there are queued targets,
		#remove the target from the queue and update the current target
		if global_position.distance_to(current_target) < 10 and len(target_array) > 0:
			emit_signal("reached_target")
			if patrolling: 
				target_array.append(current_target)
			
			current_target = target_array[0]
			
			target_array.remove(0)
		
		#if we are close to the last target, set stopped to true
		elif global_position.distance_to(current_target) < 10:
			emit_signal("reached_target")
			
			stop_moving()

		if int(global_position.distance_to(current_target)) > 1:
			self.rotation = lerp_angle(self.rotation, (current_target - self.global_position).normalized().angle() + PI/2, self.turn_weight)
		#print(position.move_toward(current_target, delta*current_speed))
		if not stopped:
			self.calc_new_velocity()
			global_position = global_position.move_toward(get_movement_vector(), delta*(velocity_vector.length()))
		
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func _process(delta):
	
	# taking out the bars, so this method doesn't do anything yet.
	pass
	
func set_firing_target(firing_target):
	
	# idk how to do this one yet
	self.firing_target = firing_target

# update this later, once turrets are added
func _on_ShotTimer_timeout():
	
	pass
	
# TODO: make a bullet deal damage.
func take_damage(bullet):
	
	pass

func check_removal():
	if self.get_health() <= 0:
		# free the ship from the scene
		emit_signal("ship_unit_lost", self)

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


func _on_Ship_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == 1 \
	and event.pressed:
		#print(event)
		print("actually clicked ON ship, event status:", event.pressed)
		
		self.on_click()
		
	if event is InputEventMouseButton \
	and event.button_index == 1 \
	and !event.pressed:
		print("mouse released")
