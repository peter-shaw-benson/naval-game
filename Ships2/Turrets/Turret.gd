extends Area2D

export var Bullet : PackedScene

func _ready():
	pass

func _process(delta):
	look_at(get_global_mouse_position())

	if Input.is_action_just_pressed("shoot"):
		 shoot()
	
func shoot():
	var b = Bullet.instance()
	
	get_tree().root.add_child(b)
	
	b.transform = $Barrel.global_transform
