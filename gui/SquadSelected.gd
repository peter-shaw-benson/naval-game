extends PopupPanel

var burning_color = Color("#E67E22")
var repair_color = Color("#5DADE2")
var subsystem_color = Color("9a25aa")
var healthy_color = Color("1bc32a")

var speed_color = Color("#AAB7B8")

var color_dict = {
	"burning": burning_color,
	"repairing": repair_color,
	"healthy": healthy_color
}

func _ready():
	get_node("VBoxContainer/HBoxContainer/SquadStatus").text = "HEALTHY"
	
	get_node("VBoxContainer/HBoxContainer/SpeedStatus").set("custom_colors/default_color", speed_color)


func change_font_color_squad(color):
	get_node("VBoxContainer/HBoxContainer/SquadStatus").set("custom_colors/default_color", color)
	
func subsystem_status(status):
	if status in color_dict:
		change_font_color_squad(color_dict[status])
	else:
		change_font_color_squad(subsystem_color)
	
	get_node("VBoxContainer/HBoxContainer/SquadStatus").text = status.to_upper()

func speed_status(status):
	get_node("VBoxContainer/HBoxContainer/SpeedStatus").text = status.to_upper()
	
func update_health(new_health):
	get_node("VBoxContainer/HealthBar").value = new_health

func set_max_health(max_health):
	get_node("VBoxContainer/HealthBar").max_value = max_health

func update_fuel(new_fuel):
	get_node("VBoxContainer/FuelBar").value = new_fuel

func set_max_fuel(max_fuel):
	get_node("VBoxContainer/FuelBar").max_value = max_fuel
