extends PopupPanel

export(ButtonGroup) var group

var selected_ships = []

var carrier_present = false

func get_ship_speed():
	return selected_ships[0].get_current_speed_mode()

func _ready():
	get_node("ShipSelected/Basic Actions/HBoxContainer/SpeedModes/StopButton").pressed = true

func _on_MoveButton_pressed():
	var move_event = InputEventAction.new()
	move_event.action = "move"
	move_event.pressed = true
	Input.parse_input_event(move_event)

func _on_PatrolButton_pressed():
	var patrol_event = InputEventAction.new()
	patrol_event.action = "patrol"
	patrol_event.pressed = true
	Input.parse_input_event(patrol_event)

func _on_DeselectButton_pressed():
	
	for s in selected_ships:
		s.deselect()


func set_selected_ships(new_ship_list):
	self.selected_ships = new_ship_list

func _on_ShootButton_pressed():
	#Input.action_press("shoot")
	
	var shoot_event = InputEventAction.new()
	shoot_event.action = "shoot"
	shoot_event.pressed = true
	Input.parse_input_event(shoot_event)
	
## SPEED BUTTONS
func _on_FlankButton_pressed():
	var speed_event = InputEventAction.new()
	speed_event.action = "flank speed"
	speed_event.pressed = true
	Input.parse_input_event(speed_event)

func _on_FullButton_pressed():
	var full_event = InputEventAction.new()
	full_event.action = "full ahead"
	full_event.pressed = true
	Input.parse_input_event(full_event)
	
func _on_HalfButton_pressed():
	var half_event = InputEventAction.new()
	half_event.action = "half speed"
	half_event.pressed = true
	Input.parse_input_event(half_event)

func _on_StopButton_pressed():
	var stop_event = InputEventAction.new()
	stop_event.action = "stop"
	stop_event.pressed = true
	Input.parse_input_event(stop_event)

## CARRIER SHIT
func set_carrier_present(new_status):
	carrier_present = new_status

func _on_ShipSelected_tab_selected(tab):
	# if the tab is 1 (second tab) and it's not a carrier, don't do shit.
	if tab == 1 and not carrier_present:
		return
