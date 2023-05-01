extends Node2D

var squad: Squadron

func _ready():
	pass

func init(squad_input):
	self.squad = squad_input

func _process(delta):
	update()
	
func _draw():
	
	if squad != null:
		draw_line(squad.global_position, squad.current_target, Color.green, 1.5)
	
		if len(squad.target_array) >= 1:
			draw_line(squad.current_target, squad.target_array[0], Color.green, 1.5)
			
			if len(squad.target_array) >= 2:
				for i in range(1,len(squad.target_array)):
					draw_line(squad.target_array[i-1], squad.target_array[i], Color.green, 1.5)
