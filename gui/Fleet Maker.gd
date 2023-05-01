extends Control

const Squadron = preload("res://Squad/Squadron.gd")
const Destroyer = preload("res://Ships/Destroyer.gd")

var num_destroyers = 0
var position_x = 0
var position_y = 0

func _ready():
	pass

func get_squadron():
	# Create a new squadron here, reading from the number boxes
	
	#var squad = Squadron.new()
	var ship_list = make_destroyer_array(num_destroyers)
	#print(ship_list[0].speed)
	var initial_pos = Vector2(position_x, position_y)
	
	return {"ships": ship_list,
			"position": initial_pos}

func make_destroyer_array(length):
	var destroyer_array = []
	
	for i in range(length+1):
		destroyer_array.append(Destroyer.new())
	
	return destroyer_array

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
	GameState.change_to_main_map("res://Game Map/Map 2.tscn", get_squadron())
