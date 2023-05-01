extends Node

const Ship = preload("res://Squad/Ship.gd")

static func generate_destroyer():
	# Make new destroyer
	
	var destroyer_speed = 40
	var destroyer_turn_weight = 0.1
	
	return Ship.new(destroyer_speed, destroyer_turn_weight)

static func generate_cruiser():
	var cruiser_speed = 32
	var cruiser_turn_weight = 0.08
	
	return Ship.new(cruiser_speed, cruiser_turn_weight)

static func generate_battleship():
	var battleship_speed = 25
	var battleship_turn_weight = 0.05
	
	return Ship.new(battleship_speed, battleship_turn_weight)
