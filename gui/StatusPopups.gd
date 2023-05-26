extends Popup


func _ready():
	get_node("VBoxContainer/HealthText").text = ""
	get_node("VBoxContainer/ConditionText").text = ""

func set_health(health_str):
	get_node("VBoxContainer/HealthText").text = health_str

func set_condition(condition_str):
	get_node("VBoxContainer/ConditionText").text = condition_str
