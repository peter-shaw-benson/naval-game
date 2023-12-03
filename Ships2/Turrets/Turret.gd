extends Area2D

export var Bullet : PackedScene

# bullet data here
var weaponData: Weapon

func init(weapon):
	self.weaponData = weapon

func _ready():
	pass

func _process(delta):
	look_at(get_global_mouse_position())

	if Input.is_action_just_pressed("shoot"):
		 shoot()
	
func shoot():
	var bullet = Bullet.instance()
	
	bullet.init(weaponData.get_speed(), weaponData.get_range())
	
	get_tree().root.add_child(bullet)
	
	bullet.transform = $Barrel.global_transform
