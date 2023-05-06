extends Control

var num_islands = 0
var player_faction = GameState.get_playerFaction()
#var enemy_faction

func _on_Islands_value_changed(value):
	num_islands = value

func _on_Faction_value_changed(value):
	GameState.set_playerFaction(value)


func _on_MakeFleets_pressed():
	GameState.goto_scene("res://gui/AdvancedFleetMaker.tscn")
	
	GameState.set_num_islands(num_islands)


func _on_BackButton_pressed():
	GameState.goto_scene("res://gui/MainMenu.tscn")
