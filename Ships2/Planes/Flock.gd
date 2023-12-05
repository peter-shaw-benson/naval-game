extends Node2D

const PlaneBoid = preload("res://Ships2/Planes/Plane.tscn")

export(int) var num_planes = 20

var _width = ProjectSettings.get_setting("display/window/size/width")
var _height = ProjectSettings.get_setting("display/window/size/height")

func _ready():
	for i in range(num_planes):
		_create_boid()

func _create_boid():
	var boid = PlaneBoid.instance()
	
	add_child(boid)
	boid.global_position = self.get_global_mouse_position()
	
	randomize()
	
	var direction = Vector2(round(randf()), round(randf()))
	if direction == Vector2():
		direction = Vector2(0, 1)
	
