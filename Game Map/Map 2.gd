extends Node

export var squadron_scene: PackedScene
export var island_scene: PackedScene

var squad: Squadron
var island: Island

var playerFaction

var squad_list = []

onready var LineRenderer = get_node("LineDrawer")
onready var IslandTexture = get_node("IslandTexture")

func init(squadron_list, num_islands):
	playerFaction = GameState.get_playerFaction()
	
	for s in squadron_list:
		#print(s)
		squad = squadron_scene.instance()
		
		squad.init(s.ships, s.position, s.faction)
		
		squad_list.append(squad)
		
		add_child(squad)
		
		# Connect squad hit signal to this 
		squad.connect("hit", self, "_on_squad_crash")
		squad.connect("squadron_spotted", self, "_on_squad_spotting")
		squad.connect("ship_lost", self, "_on_ship_lost")
		squad.connect("squadron_lost", self, "_on_squadron_lost")
	
	LineRenderer.init(squad_list)
	
	# Add Islands
	var screen_size = get_viewport().size
	
	var map_center = Vector2(screen_size.x / 2, screen_size.y /2)
	
	# Create the Island Instances
	if num_islands > 0:
		for i in range(num_islands):
			island = island_scene.instance()
			island.generate_new_island(map_center)
			print("made new island")
			
			# Add to scene
			add_child(island)
	
	# Hide enemy squadrons
	for s in squad_list:
		if s.faction != playerFaction:
			s.hide()
	
func place_squadron():
	# Find mouse position, set squadron position based on it
	
	# Stop placing on Left Click
	
	pass

func _input(event):
			
			#print("Left button was clicked at ", event.position)
	if event is InputEventMouseButton and event.pressed and event.button_index == 2:
		for s in squad_list:
			s.handle_right_click(event.position)

# Handle collisions with Islands
func _on_squad_crash(s):
	print("squad crashed")
	
	get_node("CrashPopup").popup_centered()
	squad_list.remove(squad_list.find(s, 0))
	
	s.queue_free()

func _on_CrashPopup_id_pressed(id):
	if id == 0:
		# Go to Main Menu
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
