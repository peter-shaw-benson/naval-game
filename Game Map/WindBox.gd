extends Control

var angle_target
var speed_target
var current_speed

func update_weather_display(angle, speed):
	#set lerp targets
	self.angle_target = angle
	self.speed_target = speed

func _physics_process(delta):
	#lerp setup for arrow rotation
	$ArrowSprite.rotation = lerp_angle($ArrowSprite.rotation, angle_target, 0.1)
	#lerp setup if we want numbers to graduate smoothly in the future
	$WindSpeedText.set_text(str(int(lerp(current_speed, speed_target, 0))) + " kt")
	current_speed = speed_target

func _ready():
	angle_target = 0
	current_speed = 0
	speed_target = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
