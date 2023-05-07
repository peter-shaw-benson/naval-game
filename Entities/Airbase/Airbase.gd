extends Area2D
class_name Airbase

export var PlaneSquadScene: PackedScene

const ScoutPlane = preload("res://Entities/Planes/ScoutPlane.gd")

signal plane_launch(plane_squad)
signal planes_recovered(plane_squad)

var scout_plane_list = [ScoutPlane.new()]

#var plane_squad_list = []
var faction = 0

var selected = false
var launching = false

var plane_dict = {"scout": [], "strike": []}

func _ready():
	pass

func init(initial_pos, plane_list, faction):
	global_position = initial_pos
	
	plane_list = scout_plane_list
	
	organize_aircraft(plane_list)
	faction = faction
	
	self.deselect()

func select():
	if faction == GameState.get_playerFaction():
		
		self.selected = true
		
		emit_signal("airbase_selected", self)
		
		get_node("ColorRect").show()

func deselect():
	
	self.selected = false
	
	emit_signal("airbase_deselected", self)
	
	get_node("ColorRect").hide()

func on_click():
	if self.selected:
		self.deselect()
	else:
		self.select()

func get_faction():
	return faction

func organize_aircraft(plane_list):
	for aircraft in plane_list:
		if aircraft.get_class() == "ScoutPlane":
			plane_dict["scout"].append(aircraft)
		else:
			plane_dict["strike"].append(aircraft)
	
	print(plane_dict)

# Press "S" for scouting, press Z for strike
# for now, scouting force is 2 scout planes 
# while strike force is 
func handle_right_click(placement):
	if selected:
		#print("right clicked for course")
		# Turn logic is here for now?
		if Input.is_action_pressed("scout") and len(plane_dict["scout"]) > 0:
			# Send planes
			send_scout_force(placement)
			
		elif Input.is_action_pressed("strike") and len(plane_dict["strike"]) > 0:
			send_strike_force(placement)

func _unhandled_input(event):
	
	# Deselct when clicked outside the squadron
	# going to also include event being a certain distance away – a total hack
	if event is InputEventMouseButton \
	and event.button_index == 1 \
	and event.pressed and global_position.distance_to(event.position) > 50:
		if self.selected:
			self.deselect()

func send_scout_force(placement):
	# Instance plane scene
	var plane_squad = PlaneSquadScene.instance()
	
	var plane_list = plane_dict["scout"]
	var initial_pos = global_position
	var target = placement
	
	# Init plane scene
	# initial posiiton is airbase position
	# plane composition is the scout planes
	# faction
	plane_squad.init(plane_list, initial_pos, target, faction, false)
	
	emit_signal("plane_launch", plane_squad)
	
	plane_squad.connect("planes_recovered", self, "plane_squad_recovered")
	
	plane_dict["scout"].remove(0)
	
	print("sent scout force to ", placement)
	
func send_strike_force(placement):
	var plane_squad = PlaneSquadScene.instance()
	
	var plane_list = plane_dict["strike"]
	var initial_pos = global_position
	var target = placement
	
	# Init plane scene
	# initial posiiton is airbase position
	# plane composition is the scout planes
	# faction
	plane_squad.init(plane_list, initial_pos, target, faction, true)
	
	emit_signal("plane_launch", plane_squad)
	
	plane_squad.connect("planes_recovered", self, "plane_squad_recovered")
	
	plane_dict["strike"].remove(0)
	
	print("sent strike force to ", placement)


func _on_AirbaseArea_input_event(viewport, event, shape_idx):
	#print("mouse click in airbase?")
	
	if event is InputEventMouseButton \
	and event.button_index == 1 \
	and event.pressed:
		self.on_click()

func plane_squad_recovered(plane_squad):
	#print("recovering at base")
	
	if plane_squad.get_strike():
		plane_dict["strike"].append(plane_squad)
	else:
		plane_dict["scout"].append(plane_squad)
	
	plane_squad.queue_free()
		
	emit_signal("planes_recovered", plane_squad)

