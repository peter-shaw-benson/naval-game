class_name Ship
extends "../CombatUnit.gd"

# Navigation Variables
var ship_name: String

func set_name(ship_name):
	self.ship_name = ship_name

func get_name(): return self.ship_name

func _to_string():
	var s = ""
	s += "\nSHIP CLASS " + self.entity_class + "\n"
	s += self.ship_name + "\n"
	
	# Add parent to string?

	return s
