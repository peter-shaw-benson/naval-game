extends Node

export var squadron_scene: PackedScene
export var island_scene: PackedScene
export var airbase_scene: PackedScene

var squad: Squadron
var island: Island
var airbase: Airbase

var playerFaction

var squad_list = []
var place_list
var squadron_data

var game_time = 0

onready var LineRenderer = get_node("LineDrawer")
onready var IslandTexture = get_node("IslandTexture")

func init(squadron_data, num_islands):
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
	
	# add airbase
	airbase = airbase_scene.instance()
	airbase.init(Vector2(300, 300), [], playerFaction)
	add_child(airbase)
	
	airbase.connect("plane_launch", self, "launch_plane_squad")
	airbase.connect("planes_recovered", self, "recover_plane_squad")
	
	place_list = range(len(squadron_data))
	place_next_squadron(place_list, squadron_data)

func hide_enemies():
	print("hiding enemies")
	
	LineRenderer.init(squad_list)
	# Hide enemy squadrons, start visibility
	for s in squad_list:
		s.enable_spotting()
		
		if s.faction != playerFaction:
			s.hide()
	
func place_squadron(squad_data):
	var squad = squadron_scene.instance()
		
	squad.init(squad_data.ships, get_viewport().get_mouse_position(), squad_data.faction)
		
	squad_list.append(squad)
		
	add_child(squad)
	
	squad.connect("hit", self, "_on_squad_crash")
	squad.connect("squadron_spotted", self, "_on_squad_spotting")
	squad.connect("ship_lost", self, "_on_ship_lost")
	squad.connect("squadron_lost", self, "_on_squadron_lost")
	squad.connect("stopped_placing", self, "_on_squadron_stopped_placement")
	
	squad.connect("squad_selected", self, "display_selected_squad")
	squad.connect("squad_deselected", self, "squad_deselected")
	squad.connect("update_squad_info", self, "update_squad_info")
		
	#place_squadron(squad)
	# Find mouse position, set squadron position based on it
	squad.start_placing()

func place_next_squadron(place_list, squadron_data):
	print(place_list)
	print(squadron_data)
	
	if len(place_list) > 0:
		print("placing next squad, current place list:", place_list)
		var squad_index = place_list[0]
		#print(squadron_data[squad_index])
		place_squadron(squadron_data[squad_index])
		place_list.remove(0)

func _on_squadron_stopped_placement():
	if len(place_list) > 0:
		place_next_squadron(place_list, squadron_data)
	else:
		hide_enemies()
		
func _input(event):
			
			#print("Left button was clicked at ", event.position)
	if event is InputEventMouseButton and event.pressed and event.button_index == 2:
		for s in squad_list:
			s.handle_right_click(event.position)
		
		airbase.handle_right_click(event.position)

# Handle collisions with Islands
func _on_squad_crash(s):
	print("squad crashed")
	
	get_node("CrashPopup").popup_centered()
	squad_list.remove(squad_list.find(s, 0))
	
	s.queue_free()

func _on_CrashPopup_id_pressed(id):
	if id == 0:
		# Go to Main Menu
		GameState.restore_budgets()
		
		GameState.goto_scene("res://gui/MainMenu.tscn")
	elif id == 1:
		# Quit Game
		get_tree().quit()

func _on_ship_lost(ship: Ship):
	var loss_text = ship.get_name() + " lost to Enemy Action!"
	
	get_node("Ship Funeral/Ship Text").text = loss_text
	
	get_node("Ship Funeral").popup()
	get_node("Ship Popup Timer").start()

func _on_squadron_lost(s: Squadron, enemy_squad):
	squad_list.remove(squad_list.find(s, 0))
	
	s.queue_free()
	
	if enemy_squad:
		enemy_squad.exit_combat()

func _on_squad_spotting(sq, enemy_location):
	var enemy_squad = get_squadron_at(enemy_location)
	
	sq.set_enemy_squadron(enemy_squad)
	

func _on_Ship_Popup_Timer_timeout():
	get_node("Ship Funeral").hide()

func get_squadron_at(location):
	for s in squad_list:
		if location.distance_to(s.global_position) < 2:
			return s

func update_clock_display():
	if game_time >= 1440:
		game_time = 0
		
	var hours = int(game_time / 60)
	var minutes = game_time % 60
	
	var clock_text = "%02d:%02d" % [hours, minutes]
	
	get_node("ClockDisplay").text = clock_text

func _on_GameClock_timeout():
	game_time += 1
	
	update_clock_display()

func display_selected_squad(squad):
	get_node("SquadSelected").show()
	
	var squad_text = squad.get_squad_info()
	
	get_node("SquadSelected/SquadInfo").text = squad_text

func squad_deselected(squad):
	get_node("SquadSelected").hide()

func update_squad_info(new_info):
	if get_node("SquadSelected").visible == true:
		get_node("SquadSelected/SquadInfo").text = new_info

# PLANE STUFF

func place_airbase():
	pass

func launch_plane_squad(plane_squad):
	add_child(plane_squad)

func recover_plane_squad(plane_squad):
	plane_squad.queue_free()
