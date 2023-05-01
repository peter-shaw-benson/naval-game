extends Node

export var squadron_scene: PackedScene
export var island_scene: PackedScene

var squad: Squadron
var island: Island

onready var LineRenderer = get_node("LineDrawer")
onready var IslandTexture = get_node("IslandTexture")

func init(squadron_data, num_islands):
	squad = squadron_scene.instance()
	
	squad.init(squadron_data.ships, squadron_data.position)
	LineRenderer.init(squad)
	
	add_child(squad)
	
	# Add Islands
	var screen_size = get_viewport().size
	
	var map_center = Vector2(screen_size.x / 2, screen_size.y /2)
	
	# Create the Island Instances
	if num_islands > 0:
		for i in range(num_islands):
			island = island_scene.instance()
			island.generate_new_island(map_center)
			print("made new island")
			
			# Add to scene
			add_child(island)

func _ready():
	
	pass

func _input(event):
			
			#print("Left button was clicked at ", event.position)
	if event is InputEventMouseButton and event.pressed and event.button_index == 2:
		squad.handle_right_click(event.position)
