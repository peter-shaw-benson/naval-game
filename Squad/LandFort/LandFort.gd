extends ShipSquadron
class_name LandFort

func _ready():
	pass

func select():
	pass

func stop_placing():
	#print("stopped placing: " + self.get_name())
	placing = false

	emit_signal("stopped_placing")
	
	get_node("IslandCollision").disabled = true
	#print(get_node("IslandCollision").disabled)
	detector.enable_spotting()

func get_damaged_ship():
	return units[randi() % units.size()]
