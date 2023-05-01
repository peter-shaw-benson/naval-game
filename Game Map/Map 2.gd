extends Node

export var squadron_scene: PackedScene

var squad: Squadron

onready var LineRenderer = get_node("LineDrawer")
onready var IslandTexture = get_node("IslandTexture")

func init(squadron_data):
	squad = squadron_scene.instance()
	
	squad.init(squadron_data.ships, squadron_data.position)
	LineRenderer.init(squad)
	
	IslandTexture.generate_noise()
	
	#add_child(squad)

func _ready():
	
	pass

func _input(event):
			
			#print("Left button was clicked at ", event.position)
	if event is InputEventMouseButton and event.pressed and event.button_index == 2:
		squad.handle_right_click(event.position)
