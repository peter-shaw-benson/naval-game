class_name DetectionArea
extends Area2D

signal entered_spotting_area(area_parent)
signal left_spotting_area()

func _ready():
	pass
	
func init(visibility):
	get_node("CollisionShape2D").shape.radius = visibility
	
	get_node("CollisionShape2D").disabled = true
	
	#print(get_node("CollisionShape2D").shape.radius)
	
func enable_spotting():
	get_node("CollisionShape2D").disabled = false

func _on_Detection_Area_area_entered(area):
	#print("spotting (detector node)")
	emit_signal("entered_spotting_area", area.get_parent())


func _on_Detection_Area_area_exited(area):
	emit_signal("left_spotting_area")

func to_string():
	var s = ""
	
	s += str(global_position) + "\n"
	s += str(get_node("CollisionShape2D").shape.radius)
