class_name ZoomCamera
extends Camera2D

# Lower cap for the `_zoom_level`.
export var min_zoom := 0.5
# Upper cap for the `_zoom_level`.
export var max_zoom := 1.0
# Controls how much we increase or decrease the `_zoom_level` on every turn of the scroll wheel.
export var zoom_factor := 0.1
# Duration of the zoom's tween animation.
export var zoom_duration := 0.2

# The camera's target zoom level.
var _zoom_level := 1.0 setget _set_zoom_level

# We store a reference to the scene's tween node.
onready var tween: Tween = $Tween


# Movement:
export var movement_factor = 50
var min_camera_pos = Vector2(0,0)
var max_camera_pos: Vector2
var map_center: Vector2

var is_moving = false
var move_direction = "up"

func _ready():
	var screen_size = get_viewport().size
	
	max_camera_pos = screen_size
	
	map_center = Vector2(screen_size.x / 2, screen_size.y /2)
	
func _set_zoom_level(value: float) -> void:
	# We limit the value between `min_zoom` and `max_zoom`
	_zoom_level = clamp(value, min_zoom, max_zoom)
	# Then, we ask the tween node to animate the camera's `zoom` property from its current value
	# to the target zoom level.
	tween.interpolate_property(
		self,
		"zoom",
		zoom,
		Vector2(_zoom_level, _zoom_level),
		zoom_duration,
		tween.TRANS_SINE,
		# Easing out means we start fast and slow down as we reach the target value.
		tween.EASE_OUT
	)
	tween.start()

func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		# Inside a given class, we need to either write `self._zoom_level = ...` or explicitly
		# call the setter function to use it.
		#print("zooming in")
		_set_zoom_level(_zoom_level - zoom_factor)
		
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(_zoom_level + zoom_factor)

func _input(event):
	# arrow keys for moving
	if event.is_action_pressed("ui_up"):
		is_moving = true
		move_direction = "up"
	if event.is_action_pressed("ui_down"):
		is_moving = true
		move_direction = "down"
		
	if event.is_action_pressed("ui_left"):
		is_moving = true
		move_direction = "left"
	if event.is_action_pressed("ui_right"):
		is_moving = true
		move_direction = "right"
		
	if event.is_action_released("ui_up"):
		is_moving = false
	if event.is_action_released("ui_down"):
		is_moving = false
	if event.is_action_released("ui_left"):
		is_moving = false
	if event.is_action_released("ui_right"):
		is_moving = false
		
func _process(delta):
	if is_moving:
		if move_direction == "up":
			self.position.y -= movement_factor
		if move_direction == "down":
			self.position.y += movement_factor
			
		if move_direction == "left":
			self.position.x -= movement_factor
		if move_direction == "right":
			self.position.x += movement_factor
		
	self.position.x = clamp(self.position.x, self.min_camera_pos.x, self.max_camera_pos.x)
	self.position.y = clamp(self.position.y, self.min_camera_pos.y, self.max_camera_pos.y)

func get_camera_offset():
	return self.position
