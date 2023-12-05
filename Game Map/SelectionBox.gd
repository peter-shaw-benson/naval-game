extends Node2D


# new approach to unit selection:
var dragging = false  # Are we currently dragging?
var selected = []  # Array of selected units.
var drag_start = Vector2.ZERO  # Location where drag began.
var select_rect = RectangleShape2D.new()  # Collision shape for drag box.


### SELECTION
func _ready():
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			# We only want to start a drag if there's no selection.
			if selected.size() == 0:
				dragging = true
				drag_start = event.position
		elif dragging:
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
			
			# selected is an array of dicts
			for item in selected:
				# need to check if it's in the right group
				if item.collider.is_in_group("ships"):
					item.collider.select()

	if event is InputEventMouseMotion and dragging:
		update()

func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start),
				Color(.9, .9, .9, 0.15), true)

func _process(delta):
	update()
