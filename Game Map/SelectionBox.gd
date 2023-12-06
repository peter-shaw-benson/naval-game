extends Node2D


# new approach to unit selection:
var dragging = false  # Are we currently dragging?
var selected = []  # Array of selected units.
var drag_start = Vector2.ZERO  # Location where drag began.
var select_rect = RectangleShape2D.new()  # Collision shape for drag box.

var dragging_right = false
var initial_right_mouse_pos = Vector2.ZERO
var final_right_mouse_pos = Vector2.ZERO

# implement this later lmao
var formations = [
	"line",
	"arrow"
]

# we should ONLY use this one
var selected_ships = []

### SELECTION
func _ready():
	selected = [] 
	selected_ships = []
	
func _input(event):
			#print("Left button was clicked at ", event.position)
	if event is InputEventMouseButton and event.button_index == 2:
		if event.pressed:
			dragging_right = true
			initial_right_mouse_pos = event.position
			
			#print("right mouse clicked")
			#get_parent().get_node("LineDrawer").set_temp_target(event.position)
			
			if len(selected_ships) == 1:
				selected_ships[0].set_temp_target(event.position)
				
			elif len(selected_ships) > 1:
				set_temp_squadron_targets(event.position)
				
			
		# if the right mouse is released 
		# need to add a "final angle" to the ship targeting
		else:
			dragging_right = false
			final_right_mouse_pos = event.position
			
			
			if len(selected_ships) == 1:
				var selected_ship: ShipScene = selected_ships[0]
				
				if selected_ship.is_in_group("player") and selected_ship.is_in_group("ship"):
					selected_ship.handle_right_click(initial_right_mouse_pos)
					
			# if there's multiple ships
			else:
				move_in_formation(initial_right_mouse_pos)
			
			if len(selected_ships) == 1:
				var selected_ship: ShipScene = selected_ships[0]
				
				if selected_ship.is_in_group("player") and selected_ship.is_in_group("ship"):
					selected_ship.handle_final_turn(final_right_mouse_pos)
			else:
				self.handle_squadron_turn(final_right_mouse_pos)
				
			
			

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		
		#print(" left mouse event in selection box")
		if event.pressed:
			#print(" left mouse press in selection box")
			#print("selected array: ", selected)
			# We only want to start a drag if there's no selection.
			if selected.size() == 0:
				dragging = true
				drag_start = event.position
			
			else:
				selected = []
				selected_ships = []
				
		elif dragging:
			#print("left mouse release in selection box")
			# Button released while dragging.
			dragging = false
			
			update()
			
			var drag_end = event.position
			select_rect.extents = (drag_end - drag_start) / 2
			
			var space = get_world_2d().direct_space_state
			# this gets the boundaries of the rectangle, which we can then check what's in it
			var query = Physics2DShapeQueryParameters.new()
			query.set_shape(select_rect)
			query.transform = Transform2D(0, (drag_end + drag_start) / 2)
			# this is what actually finds what's selected
			selected = space.intersect_shape(query)
			
			#print(selected)
			
			# selected is an array of dicts
			for item in selected:
				# need to check if it's in the right group
				
				if item.collider.is_in_group("ship") and not item.collider in selected_ships:
					selected_ships.append(item.collider)
				
				#print(item.collider)
					item.collider.select()

	if event is InputEventMouseMotion and dragging:
		update()

func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start),
				Color(.9, .9, .9, 0.15), true)
				
	if dragging_right:
		draw_line(initial_right_mouse_pos, get_global_mouse_position(), Color.purple, 1.0)

func _process(delta):
	update()

func move_in_formation(event_position):
	if Input.is_action_pressed("modifier"):
					
		for s in selected_ships:
			#s.handle_right_click(event_position)
			pass
		
	else:
		if len(selected_ships) > 1:
			# here, we find the average position of all the ships in the array
			var average_position = get_average_ship_position()
			
			# then, we find the offset between the average position and the placement
			# this is the vector from the ship cluster to the target
			var target_vector = event_position - average_position
		
			# finally, we create "virtual targets" for all the ships, and handle the right click
			var virtual_target = Vector2(0,0)
			
			#print(selected_ships)
			#print(selected)
			for s in selected_ships:
				virtual_target = s.global_position + target_vector
				s.handle_right_click(virtual_target)

func set_temp_squadron_targets(temp_target):
	# find the average position
	var average_position = get_average_ship_position()
	
	# then, we find the offset between the average position and the placement
	# this is the vector from the ship cluster to the target
	var target_vector = temp_target - average_position

	# finally, we create "virtual targets" for all the ships, and handle the right click
	var virtual_target = Vector2(0,0)
	
	#print(selected_ships)
	#print(selected)
	for s in selected_ships:
		virtual_target = s.global_position + target_vector
		s.set_temp_target(virtual_target)
		

func handle_squadron_turn(mouse_turn_target):
	
		if len(selected_ships) > 1:
			# here, we find the average position of all the ships in the array
			var average_position = get_average_ship_position()
			
			# then, we find the offset between the average position and the placement
			# this is the vector from the ship cluster to the target
			var target_vector = mouse_turn_target - average_position
		
			# finally, we create "virtual targets" for all the ships, and handle the right click
			var virtual_target = Vector2(0,0)
			
			for s in selected_ships:
				virtual_target = s.global_position + target_vector
				s.handle_final_turn(virtual_target)
				
func clear_selections():
	self.selected = []

func add_ship(ship):
	
	if not ship in selected_ships:
		#print("adding ship to selected array")
		self.selected_ships.append(ship)
	
func remove_ship(ship):
	
	var ship_index = 0
	
	ship_index = selected_ships.find(ship)
	
	self.selected.remove(ship_index)
	self.selected_ships.remove(ship_index)
	
func get_average_ship_position():
	var average_position = Vector2(0,0)
			
	for s in selected_ships:
		average_position.x += s.global_position.x
		average_position.y += s.global_position.y
	
	average_position.x /= len(selected_ships)
	average_position.y /= len(selected_ships)
	
	return average_position

