extends Area2D

export var Bullet : PackedScene

# bullet data here
var weaponData: Weapon

var y_offset = 0
var num_barrels = 1

var locked = true

func init(weapon):
	# here, weapon is a dict of weapon data, y offset, and number of barrels
	self.weaponData = weapon["weapon"]
	
	self.y_offset = weapon["y_offset"]
	self.num_barrels = weapon["barrels"]
	
	self.position.y += self.y_offset
	
func _ready():
	pass

func _process(delta):
	if not locked:
		look_at(get_global_mouse_position())
	
func shoot():
	
	for b in self.num_barrels:
		# shoot one bullet per barrel
		var bullet = Bullet.instance()
		
		bullet.init(weaponData,
			self.global_position)
		
		get_tree().root.add_child(bullet)
		
		bullet.transform = $Barrel.global_transform

func unlock():
	self.locked = false

func lock():
	self.locked = true

func point_to(position):
	self.look_at(position)
