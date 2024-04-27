extends PopupPanel

export(ButtonGroup) var group

var selected_ships = []

var carrier_present = false

func get_ship_speed():
	return selected_ships[0].get_current_speed_mode()

func _ready():
	get_node("ShipSelected/Basic Actions/HBoxContainer/SpeedModes/StopButton").pressed = true

func simulate_action(sim_action):
	var action_event = InputEventAction.new()
	action_event.action = sim_action
	action_event.pressed = true
	Input.parse_input_event(action_event)

func _on_MoveButton_pressed():
	simulate_action("move")

func _on_PatrolButton_pressed():
	simulate_action("patrol")

func _on_DeselectButton_pressed():
	
	for s in selected_ships:
		s.deselect()


func set_selected_ships(new_ship_list):
	self.selected_ships = new_ship_list

func _on_ShootButton_pressed():
	#Input.action_press("shoot")
	
	simulate_action("shoot")
	
## SPEED BUTTONS
func _on_FlankButton_pressed():
	simulate_action("flank speed")

func _on_FullButton_pressed():
	simulate_action("full ahead")
	
func _on_HalfButton_pressed():
	simulate_action("half speed")

func _on_StopButton_pressed():
	simulate_action("stop")

## CARRIER SHIT
func set_carrier_present(new_status):
	carrier_present = new_status

func _on_ShipSelected_tab_selected(tab):
	# if the tab is 1 (second tab) and it's not a carrier, don't do shit.
	if tab == 1 and not carrier_present:
		return


func _on_LaunchScout_pressed():
	simulate_action("scout")
	pass # Replace with function body.


func _on_Launch_Fighters_pressed():
	simulate_action("fighter")
	pass # Replace with function body.


func _on_LaunchStrike_pressed():
	simulate_action("strike")
	pass # Replace with function body.


func _on_LaunchDiveBombers_pressed():
	simulate_action("dive")
	pass # Replace with function body.
