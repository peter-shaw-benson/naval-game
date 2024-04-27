extends PopupPanel

export(ButtonGroup) var group

var selected_ships = []

var carrier_present = false

func get_ship_speed():
	return selected_ships[0].get_current_speed_mode()

func _ready():
	get_node("ShipSelected/Basic Actions/HBoxContainer/SpeedModes/StopButton").pressed = true

func _on_MoveButton_pressed():
	#Input.action_press("")
	pass # Replace with function body.


func _on_PatrolButton_pressed():
	var patrol_event = InputEventAction.new()
	patrol_event.action = "patrol"
	patrol_event.pressed = true
	Input.parse_input_event(patrol_event)
#
#	patrol_event.pressed = false
#	Input.parse_input_event(patrol_event)
	pass # Replace with function body.


func _on_DeselectButton_pressed():
	var new_deselect_event = InputEventMouseButton.new()
	new_deselect_event.position = Vector2(-10000, -10000)
	
	new_deselect_event.pressed = true
	Input.parse_input_event(new_deselect_event)


func set_selected_ships(new_ship_list):
	self.selected_ships = new_ship_list

func _on_ShootButton_pressed():
	Input.action_press("shoot")
	pass # Replace with function body.


## SPEED BUTTONS
func _on_FlankButton_pressed():
	var speed_event = InputEventAction.new()
	speed_event.action = "flank speed"
	speed_event.pressed = true
	Input.parse_input_event(speed_event)
#
#	speed_event.pressed = false
#	Input.parse_input_event(speed_event)
	
	print("pressed flank button")
	#Input.action_press("flank speed")
	pass # Replace with function body.


func _on_FullButton_pressed():
	var full_event = InputEventAction.new()
	full_event.action = "full ahead"
	full_event.pressed = true
	Input.parse_input_event(full_event)
#
#	full_event.pressed = false
#	Input.parse_input_event(full_event)
	
	print("pressed full button")
	
	pass # Replace with function body.


func _on_HalfButton_pressed():
	var half_event = InputEventAction.new()
	half_event.action = "half speed"
	half_event.pressed = true
	Input.parse_input_event(half_event)
#
#	half_event.pressed = false
#	Input.parse_input_event(half_event)
	
	print("pressed half button")
	
	pass # Replace with function body.


func _on_StopButton_pressed():
	var stop_event = InputEventAction.new()
	stop_event.action = "stop"
	stop_event.pressed = true
	Input.parse_input_event(stop_event)
#
#	stop_event.pressed = false
#	Input.parse_input_event(stop_event)
	
	print("pressed stop button")
	
	pass # Replace with function body.


## CARRIER SHIT
func set_carrier_present(new_status):
	carrier_present = new_status

func _on_ShipSelected_tab_selected(tab):
	# if the tab is 1 (second tab) and it's not a carrier, don't do shit.
	if tab == 1 and not carrier_present:
		return
