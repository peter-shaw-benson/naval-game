extends Area2D

func get_min_speed():
	
	if len(ships) == 0:
		return 0
	else:
		var min_speed = ships[0].get_speed()
		
		for ship in ships:
			if ship.get_speed() < min_speed:
				min_speed = ship.get_speed()
		
		return min_speed

func get_min_turn_weight():
	
	if len(ships) == 0:
		return 0
	else:
		var min_turn_weight = ships[0].get_turn_weight()
		
		for ship in ships:
			if ship.get_turn_weight() < min_turn_weight:
				min_turn_weight = ship.get_turn_weight()
		
		return min_turn_weight

func get_visibility():
	if len(ships) == 0:
		return 0
	else:
		var vis = ships[0].get_visibility()
		
		for ship in ships:
			if ship.get_visibility() > vis:
				vis = ship.get_visibility()
		
		return vis
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
