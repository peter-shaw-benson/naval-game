extends Control

const Squadron = preload("res://Squad/Squadron.gd")

func _ready():
	pass


func create_squadron():
	# Create a new squadron here, reading from the number boxes
	
	pass


func _on_BackButton_pressed():
	GameState.goto_scene("res://gui/MainMenu.tscn")
