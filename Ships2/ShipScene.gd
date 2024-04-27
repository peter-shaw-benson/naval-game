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
		handle_ship_inputs(event)

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
	
	update_healthbar()
