extends Control

var generator

func _ready():
	pass

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_StartButton_pressed():
	GameState.goto_scene("res://gui/Fleet Maker.tscn")

func _on_Custom_Game_pressed():
	GameState.goto_scene("res://gui/Primary Settings.tscn")
	#GameState.goto_scene("res://gui/AdvancedFleetMaker.tscn")
