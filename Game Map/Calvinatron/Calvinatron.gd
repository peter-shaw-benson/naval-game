extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func set_new_targets(squad_list):
	for squad in squad_list:
		if squad.faction != GameState.get_playerFaction():
			squad.selected = true
			var screen_size = get_viewport().size
			var random_coords = Vector2(rand_range(1, screen_size.x), rand_range(1, screen_size.y))
			squad.current_target = random_coords

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
