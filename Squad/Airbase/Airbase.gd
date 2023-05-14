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
	self.scale = Vector2(0.6, 0.6)

func init(plane_list, initial_pos, faction):
	global_position = initial_pos
	
	plane_list = scout_plane_list
	
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
		else:
			plane_dict["strike"].append(aircraft)
	

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

func send_out_planes(placement, type):
	var plane_squad = PlaneSquadScene.instance()
	
	var plane_list = plane_dict[type]
	var initial_pos = global_position
	var target = placement
	var is_strike = false
	
	# Init plane scene
	# initial posiiton is airbase position
	# plane composition is the scout planes
	# faction
	if type == "strike":
		is_strike = true
		
	plane_squad.init(plane_list, initial_pos, target, faction, is_strike)
	
	emit_signal("plane_launch", plane_squad)
	
	plane_squad.connect("planes_recovered", self, "plane_squad_recovered")
	
	plane_dict[type].remove(0)
	
	print("sent planes to ", placement)

func plane_squad_recovered(plane_squad):
	#print("recovering at base")
	
	if plane_squad.get_strike():
		plane_dict["strike"].append(plane_squad)
	else:
		plane_dict["scout"].append(plane_squad)
	
	plane_squad.queue_free()
		
	emit_signal("planes_recovered", plane_squad)

