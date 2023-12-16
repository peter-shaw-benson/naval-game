extends Node2D

var ship_list: Array

var temp_target = Vector2(0,0)

var camera: ZoomCamera
var camera_offset: Vector2


func add_camera(new_camera):
	#print(camera)
	camera = new_camera
	camera_offset = camera.get_camera_offset()

func _ready():
	pass

func init(ship_list):
	self.ship_list = ship_list

func _process(delta):
	update()
	
func _draw():
	#draw_circle(Vector2(400, 300), 5, Color.black)
	
	if ship_list != null:
		camera_offset = camera.get_camera_offset()
		print(camera_offset)
			
		for ship in ship_list:
			#draw_circle(ship.global_position, ship.get_visibility()*7, Color8(195, 155, 211, 50))
			#draw_circle(ship.global_position, ship.get_hiding(), Color8(211, 84, 0, 40))
			if ship and ship.get_path_showing():
				if ship.is_patrolling() == false:
					if Input.is_action_pressed("right_click") and ship.selected:
						# kinda a hacky way to do it, but works with the new released logic
						draw_line(ship.position + camera_offset, ship.get_temp_target() + camera_offset, Color.green, 1.5)
					else:
						draw_line(ship.position + camera_offset, ship.current_target + camera_offset, Color.green, 1.5)
				
				if !("PlaneSquad" in ship.get_name()) and len(ship.target_array) >= 1:
					draw_line(ship.current_target + camera_offset, ship.target_array[0] + camera_offset, Color.green, 1.5)
					
					if len(ship.target_array) >= 2:
						for i in range(1,len(ship.target_array)):
							draw_line(ship.target_array[i-1] + camera_offset, ship.target_array[i] + camera_offset, Color.green, 1.5)

func set_temp_target(temp_target):
	self.temp_target = temp_target
