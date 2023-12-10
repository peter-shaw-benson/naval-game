class_name DetectionArea
extends Area2D

var faction

func _ready():
	pass
	
func init(visibility, faction):
	get_node("CollisionShape2D").shape.radius = visibility
	
	get_node("CollisionShape2D").disabled = true
	
	self.faction = faction
	
	if self.faction != GameState.get_playerFaction():
		get_node("DetectionLight").visible = false
	
	#print(get_node("CollisionShape2D").shape.radius)
	
func enable_spotting():
	get_node("CollisionShape2D").disabled = false

func to_string():
	var s = ""
	
	s += str(global_position) + "\n"
	s += str(get_node("CollisionShape2D").shape.radius)


func _on_DetectionArea_body_entered(body):
	# test if it's from another faction – if so, show it
	
	var fact_string = "faction_" + str(self.faction)
	
	if not body.is_in_group(fact_string):
		body.detect()

func _on_DetectionArea_body_exited(body):
	# hide it (if it's from another faction)
	var fact_string = "faction_" + str(self.faction)
	
	if not body.is_in_group(fact_string):
		body.un_detect()
