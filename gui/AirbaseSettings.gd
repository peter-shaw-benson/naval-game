extends Control

var ScoutPlane = preload("res://Entities/Planes/ScoutPlane.gd")
var DiveBomber = preload("res://Entities/Planes/DiveBomber.gd")
var TorpBomber = preload("res://Entities/Planes/TorpBomber.gd")
var LevelBomber = preload("res://Entities/Planes/LevelBomber.gd")
var Fighter = preload("res://Entities/Planes/Fighter.gd")

var LandFortEntity = preload("res://Entities/Other/LandFortEntity.gd")

var player_carriers = 0

var player_airbases = 0
var player_scouts = 1
var player_strikes = 0
var player_bombers = 0

var enemy_faction = 0
var enemy_airbases = 0
var enemy_scouts = 1
var enemy_strikes = 0
var enemy_bombers = 0

var airbase_data = {"player_airbases": 0, \
				"player_plane_list": [],\
				"enemy_airbases": 0, \
				"enemy_plane_list": []}
				
var strike_multiplier = GameState.get_strike_multiplier()

# Land forts
var player_forts = 0
var enemy_forts = 0

func _on_MakeFleets_pressed():
	
	if player_carriers > 0:
		
		var player_carrier = {"faction": GameState.get_playerFaction(),
							"type": "carrier"}
		
		GameState.add_unit(player_carrier)
	
	#print(make_player_plane_list())
	
	if player_airbases == 1:
		var player_airbase = {\
							"planes": make_player_plane_list(),
							"faction": GameState.get_playerFaction(),
							"type": "airbase"}
	
		GameState.add_unit(player_airbase)
	
	if enemy_airbases == 1:
		var enemy_airbase = {\
							"planes": make_enemy_plane_list(),
							"faction": enemy_faction,
							"type": "airbase"}
							
		#print("enemy airbase faction:" + str(enemy_faction))
		
		GameState.add_unit(enemy_airbase)
	
	if player_forts >= 1:
		for f in range(player_forts):
			GameState.add_unit(make_fort(GameState.get_playerFaction()))
	
	if enemy_forts >= 1:
		for f in range(enemy_forts):
			GameState.add_unit(make_fort(enemy_faction))
	
	GameState.goto_scene("res://gui/AdvancedFleetMaker.tscn")

func _on_BackButton_pressed():
	GameState.goto_scene("res://gui/MainMenu.tscn")

func make_player_plane_list():
	var plane_list = []
	
	for i in range(player_scouts):
		plane_list.append(ScoutPlane.new())
	
	for i in range(player_strikes*strike_multiplier):
		plane_list.append(DiveBomber.new())
		plane_list.append(TorpBomber.new())
	
	for i in range(player_bombers):
		plane_list.append(LevelBomber.new())
	
	# this is temporary
	plane_list.append(Fighter.new())
	
	return plane_list
	
func make_enemy_plane_list():
	var plane_list = []
	
	for i in range(enemy_scouts):
		plane_list.append(ScoutPlane.new())
	
	for i in range(enemy_strikes):
		plane_list.append(DiveBomber.new())
		plane_list.append(TorpBomber.new())
	
	for i in range(enemy_bombers):
		plane_list.append(LevelBomber.new())
	
	return plane_list

func make_fort(input_faction):
	return {"ships": [LandFortEntity.new()],
			"position": Vector2(0, 0),
			"faction": input_faction,
			"name": "fort",
			"type": "landfort"}

func _on_PAirbase_value_changed(value):
	player_airbases = value


func _on_PScout_value_changed(value):
	player_scouts = value


func _on_PStrike_value_changed(value):
	player_strikes = value


func _on_PBomb_value_changed(value):
	player_bombers = value


func _on_EAirbase_value_changed(value):
	enemy_airbases = value


func _on_EScout_value_changed(value):
	enemy_scouts = value
	

func _on_EStrike_value_changed(value):
	enemy_strikes = value


func _on_EBomb_value_changed(value):
	enemy_bombers = value


func _on_E_Faction_value_changed(value):
	enemy_faction = value

func _on_PCarriers_value_changed(value):
	player_carriers = value
