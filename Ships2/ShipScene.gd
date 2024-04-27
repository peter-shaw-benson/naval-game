extends CombatUnit
class_name ShipScene

func get_class(): return "ShipScene"

export var TorpedoTube: PackedScene

# this is for placing the ghost sprite
var temp_target = Vector2(0,0)

# fire stuff
var burning_ships = []
# var ongoing_fire = Fire.new()
# ignore fire for now lol
var burning_animation = false

# repairing
var repairing = false
	
func setup_specific_unit():
	self.scale = Vector2(0.6, 0.6)
	
	unlock_turrets()

func handle_right_click(placement):
	handle_right_mouse_movement(placement)

func _input(event):
	if selected:
		#print(event)
		handle_ship_inputs()

# change this (hardcode) for now.
# change arrow to the ship type later

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
	
func _process(delta):
	
	draw_ghost_sprite()
	
	## find overlapping bodies to spot
	if self.spotting_enabled:
		scan_detection_radius()
	
	#align_turrets()
	
	if selected:
		handle_ship_inputs()
	
	update_healthbar()
