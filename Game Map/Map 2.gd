extends Node

export var squadron_scene: PackedScene
export var island_scene: PackedScene
export var airbase_scene: PackedScene
export var carrier_scene: PackedScene
export var landfort_scene: PackedScene

export var ship_scene: PackedScene

export var fog_scene: PackedScene

var squad: Squadron
var island: Island
var airbase: Airbase
var ship: ShipScene

var playerFaction

var squad_list = []
var airbase_list = []

var ship_list = []

var place_list
var unit_data
var airbase_data

var game_time = 0
var paused = false
var ai_on = false

onready var LineRenderer = get_node("LineDrawer")
onready var IslandTexture = get_node("IslandTexture")

var selected = []

func init(input_unit_list, num_islands):
	# Display stuff
	var screen_size = get_viewport().size
	
	var map_center = Vector2(screen_size.x / 2, screen_size.y /2)
	
	update_clock_display()
	get_node("GameClock").start()
	# Create the Island Instances
	if num_islands > 0:
		for i in range(num_islands):
			island = island_scene.instance()
			island.generate_new_island(map_center)
			print("made new island")
			
			# Add to scene
			add_child(island)
	
	playerFaction = GameState.get_playerFaction()
	
	# surprisingly, this might actually work?
	unit_data = input_unit_list
	place_list = range(len(unit_data))
	place_next_unit(place_list)
	
	get_node("SelectionBox").clear_selections()

func hide_enemies():
	print("hiding enemies")
	
	#print(squad_list)
	LineRenderer.init(squad_list)
	# Hide enemy squadrons, start visibility
	for s in squad_list:
		s.enable_spotting()
		
		if s.faction != playerFaction:
			s.hide()
			s.set_path_showing(false)
			
	for s in ship_list:
		s.enable_spotting()
		
		if s.faction != playerFaction:
			s.hide()
			s.set_path_showing(false)
			
	LineRenderer.init(ship_list)
	
	for a in airbase_list:
		if a.faction != playerFaction:
			a.hide()
	
func place_squadron(squad_data, landfort=false):
	var squad
	
	if landfort:
		print("placing land fort")
		squad = landfort_scene.instance()
	else:
		squad = squadron_scene.instance()
		
	squad.init(squad_data.ships, get_viewport().get_mouse_position(), 
	squad_data.faction, squad_data.type)
		
	squad_list.append(squad)
		
	add_child(squad)
	
	squad.connect("hit", self, "_on_squad_crash")
	squad.connect("ship_lost", self, "_on_ship_lost")
	squad.connect("squadron_lost", self, "_on_squadron_lost")
	squad.connect("stopped_placing", self, "_on_squadron_stopped_placement")
	
	squad.connect("squad_selected", self, "display_selected_squad")
	squad.connect("squad_deselected", self, "squad_deselected")
	squad.connect("update_squad_info", self, "update_squad_info")
		
	#place_squadron(squad)
	# Find mouse position, set squadron position based on it
	squad.start_placing()

func place_ship(ship_data):
	var ship = ship_scene.instance()
		
	ship.init(ship_data.ship, get_viewport().get_mouse_position(), 
	ship_data.faction, ship_data.unit_type)
		
	ship_list.append(ship)
		
	add_child(ship)
	
	ship.connect("hit", self, "_on_squad_crash")
	ship.connect("ship_lost", self, "_on_ship_lost")
	ship.connect("stopped_placing", self, "_on_squadron_stopped_placement")
	
	ship.connect("ship_selected", self, "add_ship_to_selected")
	ship.connect("ship_deselected", self, "remove_ship_from_selected")
	
	# Find mouse position, set ship position based on it
	ship.start_placing()

func place_airbase(airbase_data):
	var airbase = airbase_scene.instance()
	airbase.init(airbase_data["planes"], get_viewport().get_mouse_position(), 
	airbase_data["faction"], airbase_data["type"])
	
	airbase_list.append(airbase)
	
	add_child(airbase)
	
	airbase.connect("plane_launch", self, "launch_plane_squad")
	airbase.connect("planes_recovered", self, "recover_plane_squad")
	airbase.connect("stopped_placing", self, "_on_squadron_stopped_placement")
		
	airbase.start_placing()

func place_carrier(carrier_data):
	var carrier = carrier_scene.instance()
	
	carrier.init([], get_viewport().get_mouse_position(), 
	carrier_data.faction, carrier_data.type)
		
	squad_list.append(carrier)
		
	add_child(carrier)
	
	carrier.connect("hit", self, "_on_squad_crash")
	carrier.connect("ship_lost", self, "_on_ship_lost")
	carrier.connect("squadron_lost", self, "_on_squadron_lost")
	carrier.connect("stopped_placing", self, "_on_squadron_stopped_placement")
	
	carrier.connect("squad_selected", self, "display_selected_squad")
	carrier.connect("squad_deselected", self, "squad_deselected")
	carrier.connect("update_squad_info", self, "update_squad_info")
	
	# Airbase Signals
	carrier.connect("plane_launch", self, "launch_plane_squad")
	carrier.connect("planes_recovered", self, "recover_plane_squad")
	carrier.connect("stopped_placing", self, "_on_squadron_stopped_placement")

		
	#place_squadron(squad)
	# Find mouse position, set squadron position based on it
	#print("about to start placing carrier")
	carrier.start_placing()

func place_next_unit(place_list):
	#print(place_list)
	#print(unit_data)
	
	# here, the place_list is a list of the squadron data
	# 
	
	if len(place_list) > 0:
		
		#print(unit_data)
		#print("placing next squad, current place list:", place_list)
		var squad_index = place_list[0]
		#print(unit_data[squad_index])
		if unit_data[squad_index]["type"] == "carrier":
			#print("next on place list is a carrier")
			place_carrier(unit_data[squad_index])
		elif unit_data[squad_index]["type"] == "airbase":
			place_airbase(unit_data[squad_index])
		elif unit_data[squad_index]["type"] == "squadron":
			place_squadron(unit_data[squad_index])
		# new path:
		elif unit_data[squad_index]["type"] == "ship":
			place_ship(unit_data[squad_index])
		elif unit_data[squad_index]["type"] == "landfort":
			#print("found land fort!")
			place_squadron(unit_data[squad_index], true)
		place_list.remove(0)

func _on_squadron_stopped_placement():
	if len(place_list) > 0:
		place_next_unit(place_list)
	else:
		# move control nodes to the top
		raise_controls()
		
		hide_enemies()
		
		enable_combat()
		
func raise_controls():
	get_node("PauseMenu").raise()
	get_node("ClockDisplay").raise()
	get_node("Ship Funeral").raise()
	get_node("SquadSelected").raise()
	get_node("WindBox").raise()

func _input(event):
			
	if Input.is_action_pressed("pause_menu"):
		if not paused:
			handle_pause()
			
	elif Input.is_action_pressed("pause_game"):
		# Spacebar
		if not paused:
			handle_pause(false)
		else:
			unpause()


func update():
	pass
		
func handle_pause(pause_menu=true):
	get_tree().paused = true
	paused = true
	
	if pause_menu:
		get_node("PauseMenu").show()

func unpause():
	get_tree().paused = false
	paused = false

# Handle collisions with Islands
func _on_squad_crash(s):
	print("squad crashed")
	
	get_node("PauseMenu").popup_centered()
	squad_list.remove(squad_list.find(s, 0))
	
	s.queue_free()

func _on_CrashPopup_id_pressed(id):
	if id == 0:
		unpause()
		# Go to Main Menu
		GameState.reset_game()
		
		GameState.goto_scene("res://gui/MainMenu.tscn")
	elif id == 1:
		# Quit Game
		get_tree().quit()
	elif id == 2:
		get_node("PauseMenu").hide()
		unpause()

func _on_ship_lost(ship: ShipScene):
	
	ship_list.remove(ship_list.find(ship, 0))
	
	get_node("SelectionBox").remove_ship(ship)
	
	ship.queue_free()

	var loss_text = ship.get_name() + " lost to Enemy Action!"

	get_node("Ship Funeral/Ship Text").text = loss_text

	get_node("Ship Funeral").popup()
	get_node("Ship Popup Timer").start()

func _on_squadron_lost(s, enemy_squad):
	get_node("SquadSelected").hide()
	
	squad_list.remove(squad_list.find(s, 0))
	
	s.queue_free()
	
	if enemy_squad:
		enemy_squad.exit_combat()

func _on_Ship_Popup_Timer_timeout():
	pass
	#get_node("Ship Funeral").hide()
	#get_node("Ship Popup Timer").stop()

func get_squadron_at(location):
	for s in squad_list:
		if location.distance_to(s.global_position) < 2:
			return s

func update_clock_display():
	# uhhhh why do we have this
	if game_time >= 1440:
		game_time = 0
		
	var hours = int(game_time / 60)
	var minutes = game_time % 60
	
	var clock_text = "%02d:%02d" % [hours, minutes]
	
	get_node("ClockDisplay").text = clock_text

func update_weather():
	get_node("Weather").calc_new_wind_direction()
	get_node("Weather").calc_new_wind_speed()
	
	for unit in squad_list:
		if unit:
			unit.calc_new_wind_vector($Weather.get_wind_velocity_cartesian())
		
	for unit in ship_list:
		if unit:
			unit.calc_new_wind_vector($Weather.get_wind_velocity_cartesian())
		
		
	if $Weather.get_fog_gen_flag():
		var new_fog = fog_scene.instance()
		$Weather.register_fog(new_fog)
		add_child(new_fog)
		
		# when fog added, push GUI to front
		raise_controls()
		
	$Weather.update_fog()
	$WindBox.update_weather_display($Weather.get_wind_dir_angle(), $Weather.get_wind_speed_kt())

func _on_GameClock_timeout():
	game_time += 1
	update_weather()
	
	if ai_on:
		$Calvinatron.set_new_targets(squad_list)
		
	update_clock_display()

# do this later ?
#func display_selected_squad(squad):
#	get_node("SquadSelected").show()
#
#	var squad_status = squad.get_status(null)
#	var squad_health = squad.get_total_health()
#	var squad_max_health = squad.get_squadron_max_health()
#
#	get_node("SquadSelected").set_max_health(squad_max_health)
#	get_node("SquadSelected").update_health(squad_health)
#	get_node("SquadSelected").subsystem_status(squad_status)
#
#	get_node("SquadSelected").set_max_fuel(squad.get_max_fuel())
#	get_node("SquadSelected").update_fuel(squad.get_current_fuel())

func squad_deselected(squad):
	get_node("SquadSelected").hide()

func update_squad_info(new_health, new_fuel, ship_status, speed_mode):
	if get_node("SquadSelected").visible == true:
		get_node("SquadSelected").update_health(new_health)
		get_node("SquadSelected").update_fuel(new_fuel)
		
		get_node("SquadSelected").subsystem_status(ship_status)
		get_node("SquadSelected").speed_status(speed_mode)

# PLANE STUFF

func launch_plane_squad(plane_squad):
	add_child(plane_squad)
	plane_squad.calc_new_wind_vector($Weather.get_wind_velocity_cartesian())
	squad_list.append(plane_squad)

func recover_plane_squad(plane_squad):
	squad_list.remove(squad_list.find(plane_squad))
	plane_squad.queue_free()
	

## Other control things
func enable_combat():
	# only applied to ships right now
	for s in ship_list:
		s.enable_combat()


## Selection (calling the selection box)

func add_ship_to_selected(ship: ShipScene):
	
	get_node("SelectionBox").add_ship(ship)

func remove_ship_from_selected(ship: ShipScene):
	
	get_node("SelectionBox").remove_ship(ship)
