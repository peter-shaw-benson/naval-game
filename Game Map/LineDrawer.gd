extends Node2D

var squad_list: Array

func _ready():
	pass

func init(squad_list):
	self.squad_list = squad_list

func _process(delta):
	update()
	
func _draw():
	#draw_circle(Vector2(400, 300), 5, Color.black)
	
	if squad_list != null:
		for squad in squad_list:
			#draw_circle(squad.global_position, squad.get_visibility()*7, Color8(195, 155, 211, 50))
			#draw_circle(squad.global_position, squad.get_hiding(), Color8(211, 84, 0, 40))
			if squad:
				draw_line(squad.global_position, squad.current_target, Color.green, 1.5)
				
				if squad.get_name() != "PlaneSquad" \
				 and len(squad.target_array) >= 1:
					draw_line(squad.current_target, squad.target_array[0], Color.green, 1.5)
					
					if len(squad.target_array) >= 2:
						for i in range(1,len(squad.target_array)):
							draw_line(squad.target_array[i-1], squad.target_array[i], Color.green, 1.5)
