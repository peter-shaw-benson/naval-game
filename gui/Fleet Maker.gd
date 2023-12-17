extends Control

const Squadron = preload("res://Squad/Squadron.gd")
const Destroyer = preload("res://Entities/Ships/Destroyer.gd")

const ShipScene = preload("res://Ships2/ShipScene.gd")

const ScoutPlane = preload("res://Entities/Planes/ScoutPlane.gd")

var num_destroyers = 1
var position_x = 0
var position_y = 0
var num_islands = 0

var num_airbases = 1
var num_carriers = 1

var player_faction = 0
var enemy_faction = -1

func _ready():
	pass

func get_fleet():
	
	var ship_list = make_destroyer_array(num_destroyers, player_faction)
	#print(ship_list[0].speed)
	
	return ship_list

func make_destroyer_array(length, faction):
	var destroyer_array = []
	
	for i in range(length):
		# testing fletcher-class:
		var next_destroyer = FletcherClassDestroyer.new()
		#var next_destroyer = TorpDestroyer.new()
		#print(next_destroyer)
		
		destroyer_array.append({"ship": next_destroyer,
			"type": "ship",
			"unit_type": "gunboat",
			"faction": faction})
	
	return destroyer_array

func make_carrier_array(length, faction):
	var carrier_array = []
	
	for i in range(length):
		# testing fletcher-class:
		var next_carrier = CarrierEntity.new()
		#var next_destroyer = TorpDestroyer.new()
		#print(next_destroyer)
		
		carrier_array.append({"ship": next_carrier,
			"type": "carrier",
			"unit_type": "carrier",
			"faction": faction})
	
	return carrier_array

func make_enemy_fleet():
	#var squad = Squadron.new()
	var ship_list = make_destroyer_array(1, enemy_faction)
	#print(ship_list[0].speed)
	
	return ship_list

func get_fleet_list():
	var temp_list = []
		
	temp_list += get_fleet()
	temp_list += make_carrier_array(num_carriers, player_faction)
	
	if enemy_faction > 0:
		temp_list += make_enemy_fleet()
	
	print(temp_list)
	
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
	GameState.change_playerFaction(player_faction)
	
	GameState.change_to_main_map("res://Game Map/Map 2.tscn", get_fleet_list(), num_islands)

func _on_Islands_value_changed(value):
	num_islands = value

func _on_Faction_value_changed(value):
	player_faction = value
	#print(faction)
func _on_Enemy_Faction_value_changed(value):
	enemy_faction = value


func _on_Num_Carriers_value_changed(value):
	num_carriers = value
