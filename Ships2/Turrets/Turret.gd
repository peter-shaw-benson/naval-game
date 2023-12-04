extends Area2D

export var Bullet : PackedScene

# bullet data here
var weaponData: Weapon

var locked = true

func init(weapon):
	self.weaponData = weapon
	
	print(weapon.get_class())
	if weapon.get_class() == "Torpedo":
		Bullet = preload("res://Ships2/Bullets/Torpedo.tscn")

func _ready():
	pass

func _process(delta):
	if not locked:
		look_at(get_global_mouse_position())
	
func shoot():
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
