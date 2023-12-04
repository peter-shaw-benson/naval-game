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
	
	self.y_offset = weapon["offset"][1]
	self.x_offset = weapon["offset"][0]
	self.num_barrels = weapon["barrels"]
	
	# set sprite from the sprite path given in the weapon dict
	var frames = load(weapon["sprite_path"])
	get_node("AnimatedSprite").set_sprite_frames(frames)
	
	get_node("AnimatedSprite").animation = "default"
	
	#get_node("AnimatedSprite").speed_scale = 1
	
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
		
	get_node("AnimatedSprite").animation = "shoot"
	get_node("AnimatedSprite").play()
	
	get_node("AnimatedSprite").animation = "default"
	
	#if get_node("AnimatedSprite").animation == "default":
	#play_shoot_animation()

func play_shoot_animation():
	get_node("AnimatedSprite").animation = "shoot"
	get_node("AnimatedSprite").play()
	
	get_node("AnimatedSprite").animation = "default"

func unlock():
	self.locked = false

func lock():
	self.locked = true

func point_to(position):
	self.look_at(position)
