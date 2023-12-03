extends Area2D

var speed: int
var max_range: int

func init(speed, max_range):
	self.speed = speed
	self.max_range = max_range

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_Bullet_body_entered(body):
	#if body.is_in_group("mobs"):
	#	body.queue_free()
	
	queue_free()


func _on_Bullet_area_entered(area):
	pass # Replace with function body.
