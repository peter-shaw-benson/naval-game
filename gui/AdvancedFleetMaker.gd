extends Control

const Squadron = preload("res://Squad/Squadron.gd")
const Destroyer = preload("res://Entities/Ships/Destroyer.gd")
const TorpDestroyer = preload("res://Entities/Ships/TorpDestroyer.gd")
const Cruiser = preload("res://Entities/Ships/Cruiser.gd")
const Battleship = preload("res://Entities/Ships/Battleship.gd")

# Budget costs:
var destroyer_price = 10
var cruiser_price = 20
var battleship_price = 100
var torpedo_multiplier = 1.2

var num_destroyers = 1
var torp_destroyers = false
var num_cruisers = 0
var num_battleships = 0

var position_x = 0
var position_y = 0
var num_islands = 0

var faction = 0
var start_budget
var budget

var fleet_name: String

func _ready():
	# Budget should be by faction
	start_budget = GameState.get_faction_budget(str(faction))
	var budget = start_budget

	update_budget()
	

func get_squadron():
	# Create a new squadron here, reading from the number boxes
	
	#var squad = Squadron.new()
	var ship_list = make_destroyer_array(num_destroyers)
	ship_list += make_cruiser_array(num_cruisers)
	ship_list += make_battleship_array(num_battleships)
	#print(ship_list[0].speed)
	var initial_pos = Vector2(position_x, position_y)
	
	return {"ships": ship_list,
			"position": initial_pos,
			"faction": faction,
			"name": fleet_name,
			"type": "squadron"}

func make_destroyer_array(length):
	var destroyer_array = []
	
	for i in range(length):
		var next_destroyer: Ship
		
		if torp_destroyers:
			next_destroyer = TorpDestroyer.new()
		else:
			next_destroyer = Destroyer.new()
		#print(next_destroyer)
		destroyer_array.append(next_destroyer)
	
	return destroyer_array

func make_cruiser_array(length):
	var cruiser_array = []
	
	for i in range(length):
		var next_cruiser: Ship
		next_cruiser = Cruiser.new()
		#print(next_destroyer)
		cruiser_array.append(next_cruiser)
	
	return cruiser_array

func make_battleship_array(length):
	var battleship_array = []
	
	for i in range(length):
		var next_battleship: Ship
		next_battleship = Battleship.new()
		#print(next_destroyer)
		battleship_array.append(next_battleship)
	
	return battleship_array

func get_squadron_list():
	var temp_list = []
		
	temp_list.append(get_squadron())
		
	return temp_list

func _on_BackButton_pressed():
	GameState.goto_scene("res://gui/MainMenu.tscn")

func _on_Faction_value_changed(value):
	faction = value
	
	start_budget = GameState.get_faction_budget(str(faction))
	
	update_budget()
	#print(faction)

func update_budget():
	var current_budget = start_budget
	
	if torp_destroyers:
		current_budget -= torpedo_multiplier * destroyer_price * num_destroyers

	else:
		current_budget -= destroyer_price * num_destroyers
		
	current_budget -= cruiser_price * num_cruisers
	current_budget -= battleship_price * num_battleships
	
	budget = current_budget
	
	get_node("VBoxContainer/MarginContainer/options/HBoxContainer/VBoxContainer2/Budget").set_text(str(budget))

func _on_Destroyer_Number_value_changed(value):

	num_destroyers = value
		
	update_budget()

func _on_Torp_Check_toggled(button_pressed):
	
	torp_destroyers = get_node("VBoxContainer/MarginContainer/options/HBoxContainer/VBoxContainer2/Torp Check").pressed

	update_budget()

func _on_CruiserNumber_value_changed(value):
	
	num_cruisers = value
		
	update_budget()

func _on_BattleshipNumber_value_changed(value):

	num_battleships = value
		
	update_budget()


func _on_ContinueButton_pressed():
	#print(get_squadron())
	# Check if budget < 0
	if budget >= 0:
		GameState.add_unit(get_squadron())
		
		GameState.use_budget(budget, str(faction))
		print(GameState.faction_budgets)
		
		GameState.goto_scene("res://gui/AdvancedFleetMaker.tscn")
	else:
		get_node("OverBudget").popup()

func _on_PlaceButton_pressed():
	# Check if budget < 0
	if budget >= 0:
		GameState.add_unit(get_squadron())
		
		GameState.use_budget(budget, faction)
		
		#print(GameState.unit_list)
		GameState.change_to_main_map2("res://Game Map/Map 2.tscn")
	else:
		get_node("OverBudget").popup()


func _on_TF_Name_text_changed(new_text):
	fleet_name = new_text
