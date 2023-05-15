extends "res://Squad/CombatUnitsWrapper.gd"
class_name Airbase

export var PlaneSquadScene: PackedScene
export var DetectorScene: PackedScene

const ScoutPlane = preload("res://Entities/Planes/ScoutPlane.gd")

signal plane_launch(plane_squad)
signal planes_recovered(plane_squad)

var scout_plane_list = [ScoutPlane.new()]

var airbase_health = 500
var airbase_armor = 100

var launching = false

var plane_dict = {"scout": [], "strike": [], "bomber": []}



func _ready():
	self.deselect()
	
	self.scale = Vector2(0.6, 0.6)

func _process(delta):
	if placing:
		# Place squadron at mouse, until the mouse clicks
		global_position = get_viewport().get_mouse_position()

func init(plane_list, initial_pos, faction, type):
	global_position = initial_pos
	
	plane_list = plane_list
	
	type = type
	
	organize_aircraft(plane_list)
	faction = faction
	
	self.deselect()

func get_visibility():
	return 1
func get_min_speed():
	return 0
func get_total_health():
	return airbase_health
func get_total_armor():
	return airbase_armor

func start_placing():
	placing = true
	
	global_position = get_viewport().get_mouse_position()
	
func stop_placing():
	placing = false
	
	emit_signal("stopped_placing")
	
	current_target = self.global_position

func select():
	if faction == GameState.get_playerFaction():
		
		self.selected = true
		
		emit_signal("airbase_selected", self)
		
		get_node("ColorRect").show()

func deselect():
	
	self.selected = false
	
	emit_signal("airbase_deselected", self)
	
	get_node("ColorRect").hide()

func organize_aircraft(plane_list):
	for aircraft in plane_list:
		if aircraft.get_class() == "ScoutPlane":
			plane_dict["scout"].append(aircraft)
		elif aircraft.get_class() == "LevelBomber":
			plane_dict["bomber"].append(aircraft)
		else:
			plane_dict["strike"].append(aircraft)
	
	print(plane_dict)
	print(plane_dict["bomber"])
	

# Press "S" for scouting, press Z for strike
# for now, scouting force is 2 scout planes 
# while strike force is 
func handle_right_click(placement):
	if selected:
		#print("right clicked for course")
		# Turn logic is here for now?
		if Input.is_action_pressed("scout") and len(plane_dict["scout"]) > 0:
			# Send planes
			send_out_planes(placement, "scout")
			
		elif Input.is_action_pressed("strike") and len(plane_dict["strike"]) > 0:
			send_out_planes(placement, "strike")
		
		elif Input.is_action_pressed("bomb") and len(plane_dict["bomber"]) > 0:
			send_out_planes(placement, "bomber")

func send_out_planes(placement, type):
	print(type)
	
	var plane_squad = PlaneSquadScene.instance()
	
	var plane_list = [] 
	# make plane list a copy, not a reference
	for i in range(len(plane_dict[type])):
		plane_list.append(plane_dict[type][i])
	
	var initial_pos = global_position
	var target = placement
	var is_strike = false
	
	# Init plane scene
	# initial posiiton is airbase position
	# plane composition is the scout planes
	# faction
	if type != "scout":
		is_strike = true
	
	print(len(plane_list))
	
	var type_map = {"scout":"scoutPlane",
					"strike":"fighter",
					"bomber": "levelBomber"}
	
	if len(plane_list) > 0:
		#print(len(plane_list))
		plane_squad.init(plane_list, initial_pos, faction, "planesquadron")
		plane_squad.set_animation(is_strike, type_map[type])
		plane_squad.set_target(target)
		
		emit_signal("plane_launch", plane_squad)
		
		plane_squad.connect("planes_recovered", self, "plane_squad_recovered")
		plane_squad.connect("plane_squad_lost", self, "plane_squad_death")
		
		for i in range(len(plane_dict[type])):
			plane_dict[type].remove(0)
		
		#print("sent planes to ", placement)

func plane_squad_recovered(plane_squad):
	#print("recovering at base")
	#print(plane_squad)
	#print(plane_squad.get_class())
	#print(plane_squad.get_name())
	var recovered_planes = plane_squad.get_units()
	#print(recovered_planes)
	
	for p in recovered_planes:
		if plane_squad.get_sprite_type() == "fighter":
			plane_dict["strike"].append(p)
		elif plane_squad.get_sprite_type() == "levelBomber":
			plane_dict["bomber"].append(p)
		else:
			plane_dict["scout"].append(p)
	
	plane_squad.queue_free()
		
	emit_signal("planes_recovered", plane_squad)

	#print(plane_dict)

func plane_squad_death(plane_squad):
	plane_squad.queue_free()
