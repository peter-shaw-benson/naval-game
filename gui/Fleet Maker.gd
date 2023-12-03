extends Control

const Squadron = preload("res://Squad/Squadron.gd")
const Destroyer = preload("res://Entities/Ships/Destroyer.gd")

const ShipScene = preload("res://Ships2/ShipScene.gd")

const ScoutPlane = preload("res://Entities/Planes/ScoutPlane.gd")

var num_destroyers = 1
var position_x = 0
var position_y = 0
var num_islands = 0

var faction = 0
var enemy_faction = -1

func _ready():
	pass

func get_fleet():
	# Create a new squadron here, reading from the number boxes
	
	var initial_pos = Vector2(position_x, position_y)
	#var squad = Squadron.new()
	var ship_list = make_destroyer_array(num_destroyers, initial_pos)
	#print(ship_list[0].speed)
	
	return ship_list

func make_destroyer_array(length, initial_pos):
	var destroyer_array = []
	
	for i in range(length):
		var next_destroyer = Destroyer.new()
		#print(next_destroyer)
		
		destroyer_array.append({"ship": next_destroyer,
			"position": initial_pos,
			"type": "ship",
			"unit_type": "gunboat",
			"faction": faction})
	
	return destroyer_array

func make_enemy_fleet():
	var initial_pos = Vector2(400, 300)
	#var squad = Squadron.new()
	var ship_list = make_destroyer_array(2, initial_pos)
	#print(ship_list[0].speed)
	
	return ship_list

func get_fleet_list():
	var temp_list = []
		
	temp_list += get_fleet()
	
	if enemy_faction >= 0:
		temp_list += make_enemy_fleet()
		
	return temp_list

func _on_BackButton_pressed():
	GameState.goto_scene("res://gui/MainMenu.tscn")

func _on_SpinBox_value_changed(value):
	# Destoryers
	num_destroyers = value

func _on_x_pos_value_changed(value):
	position_x = value

func _on_y_pos_value_changed(value):
	position_y = value

func _on_StartButton_pressed():
	print("num_islands:", num_islands)
	# Change player faction to 
	GameState.change_playerFaction(faction)
	
	GameState.change_to_main_map("res://Game Map/Map 2.tscn", get_fleet_list(), num_islands)

func _on_Islands_value_changed(value):
	num_islands = value

func _on_Faction_value_changed(value):
	faction = value
	#print(faction)
func _on_Enemy_Faction_value_changed(value):
	enemy_faction = value
