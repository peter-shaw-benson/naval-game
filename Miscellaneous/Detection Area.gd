class_name DetectionArea
extends Area2D

var faction

func _ready():
	pass
	
func init(visibility, faction):
	get_node("DetectionBox").shape.radius = visibility
	
	#print(visibility, get_node("CollisionShape2D").shape.radius)
	
	get_node("DetectionBox").disabled = true
	
	self.faction = faction
	
	if self.faction != GameState.get_playerFaction():
		get_node("DetectionLight").visible = false
		
	var light_scale = visibility * GameState.light_detector_scale
	
	get_node("DetectionLight").scale = Vector2(light_scale, light_scale)
#
#	print("initializing detector")
#	print(get_node("DetectionBox").shape.radius)
#	print(get_node("DetectionLight").scale)
	
func enable_spotting():
	get_node("DetectionBox").disabled = false

func to_string():
	var s = ""
	
	s += str(global_position) + "\n"
	s += str(get_node("DetectionBox").shape.radius)

func get_radius():
	return get_node("DetectionBox").shape.radius

func _on_DetectionArea_body_entered(body):
	
	var fact_string = "faction_" + str(self.faction)
	var visible_string = "visible_to_" + str(self.faction)
	
	if not body.is_in_group(fact_string):
		body.detect()
		body.add_to_group(visible_string)

func _on_DetectionArea_body_exited(body):
	# hide it (if it's from another faction)
	var fact_string = "faction_" + str(self.faction)
	var visible_string = "visible_to_" + str(self.faction)
	
	if not body.is_in_group(fact_string):
		body.un_detect()
		body.remove_from_group(visible_string)
