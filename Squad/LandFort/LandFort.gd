extends ShipSquadron
class_name LandFort

func select():
	pass
	
func get_min_speed():
	return 0

func get_min_turn_weight():
	return 0
	
func deselect():
	print("deselecting land fort")
	selected = false
	get_node("Sprite").animation = "landfort" + "_basic"
	get_node("Sprite").set_frame(faction)

func stop_placing():
	#print("stopped placing: " + self.get_name())
	placing = false

	emit_signal("stopped_placing")
	
	get_node("IslandCollision").disabled = true
	#print(get_node("IslandCollision").disabled)
	detector.enable_spotting()

func get_damaged_ship():
	return units[randi() % units.size()]
