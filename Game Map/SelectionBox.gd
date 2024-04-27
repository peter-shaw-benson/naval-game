extends Node2D


# new approach to unit selection:
var dragging = false  # Are we currently dragging?
var selected = []  # Array of selected units.
var drag_start = Vector2.ZERO  # Location where drag began.
var select_rect = RectangleShape2D.new()  # Collision shape for drag box.

var dragging_right = false
var initial_right_mouse_pos = Vector2.ZERO
var final_right_mouse_pos = Vector2.ZERO
var raw_initial_right_mouse_pos = Vector2.ZERO
var transformed_pos = Vector2.ZERO
var screen_offset_pos = Vector2.ZERO


# implement this later lmao
var formations = [
	"line",
	"arrow"
]

# we should ONLY use this one
var selected_ships = []

var camera: ZoomCamera
var camera_offset: Vector2
var camera_zoom: Vector2

### SELECTION
func _ready():
	selected = [] 
	selected_ships = []
	
	
func add_camera(new_camera):
	#print(camera)
	camera = new_camera
	camera_offset = camera.get_camera_offset()
	camera_zoom = camera.zoom
	
	#print(camera)
	#print(camera_zoom)
	
func get_zoomed_offset(event_pos):
	camera_offset = camera.get_camera_offset()
	camera_zoom = camera.zoom
	
	var actual_position = event_pos * camera_zoom + camera.get_camera_offset()
	
	return actual_position# * camera_zoom
	
	
func _input(event):
			#print("Left button was clicked at ", event.position)
	# this handles right mouse buttons
	if event is InputEventMouseButton and event.button_index == 2:
		raw_initial_right_mouse_pos = event.position
		#transformed_pos = get_canvas_transform().basis_xform(event.position)
		
		var local_event = make_input_local(event)
		
		# this detects right mosue dragging – for angling later
		if event.pressed:
			dragging_right = true
			
			initial_right_mouse_pos = get_zoomed_offset(event.position)

			#initial_right_mouse_pos = get_canvas_transform().basis_xform(event.position)
			#initial_right_mouse_pos = local_event.position
			#print("raw mouse pos: ", raw_initial_right_mouse_pos)
			#print("transformed event pos: ", initial_right_mouse_pos)
			# print("screen offset pos: ", screen_offset_pos)
			#print(transformed_pos)
			#print("right mouse clicked")
			#get_parent().get_node("LineDrawer").set_temp_target(event.position)
			
			if len(selected_ships) == 1:
				#print(selected_ships)
				selected_ships[0].set_temp_target(initial_right_mouse_pos)
				
				#print("ship temp target:", selected_ships[0].get_temp_target())
				
			elif len(selected_ships) > 1:
				set_temp_squadron_targets(initial_right_mouse_pos)
				
			
		# if the right mouse is released 
		# need to add a "final angle" to the ship targeting
		else:
			dragging_right = false
			final_right_mouse_pos = get_zoomed_offset(event.position)
			
			#print("final mouse pos: ", final_right_mouse_pos)
			
			if len(selected_ships) == 1:
				var selected_ship: CombatUnit = selected_ships[0]
				
				if selected_ship.is_in_group("player") and selected_ship.is_in_group("ship"):
					selected_ship.handle_right_click(initial_right_mouse_pos)
					selected_ship.handle_final_turn(final_right_mouse_pos)
					
			# if there's multiple ships
			else:
				move_in_formation(initial_right_mouse_pos)
				self.handle_squadron_turn(final_right_mouse_pos)
			
			

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		var new_position = get_zoomed_offset(event.position)
		
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
			select_rect.extents = (get_zoomed_offset(drag_end) - get_zoomed_offset(drag_start)) / 2
			
			var space = get_world_2d().direct_space_state
			# this gets the boundaries of the rectangle, which we can then check what's in it
			var query = Physics2DShapeQueryParameters.new()
			query.set_shape(select_rect)
			query.transform = Transform2D(0, (get_zoomed_offset(drag_end) + get_zoomed_offset(drag_start)) / 2)
			# this is what actually finds what's selected
			selected = space.intersect_shape(query)
			
			#print("select extents:", select_rect.extents)
			#print(drag_end, drag_start)
			#print("drag end - start (unzoomed)", drag_end - drag_start)
			#print("drag offset - drag start (zoomed)", get_zoomed_offset(drag_end) - get_zoomed_offset(drag_start))
			#print("transform:", query.transform)
			#print(selected)
			
			# selected is an array of dicts
			for item in selected:
				
				# need to check if it's in the right group
				
				if item.collider.is_in_group("ship") and \
				 not item.collider in selected_ships and \
				item.collider.get_faction() == GameState.playerFaction:
					selected_ships.append(item.collider)
				
				#print(item.collider)
					item.collider.select()

	if event is InputEventMouseMotion and dragging:
		update()

func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, get_local_mouse_position() - drag_start),
				Color(.9, .9, .9, 0.15), true)
				
	if dragging_right:
		draw_line(raw_initial_right_mouse_pos, get_local_mouse_position(), Color.purple, 1.0)
	
	draw_circle(raw_initial_right_mouse_pos, 4, Color.green)
	draw_circle(initial_right_mouse_pos + Vector2(50, 0), 4, Color.black)
	draw_circle(final_right_mouse_pos, 4, Color.purple)
	#draw_circle(screen_offset_pos, 4, Color.yellow)

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
	
	if ship_index >= 0:
		# this line here is not good at all lmao
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

