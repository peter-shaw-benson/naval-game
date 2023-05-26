extends PopupPanel

var burning_color = Color("#E67E22")
var repair_color = Color("#5DADE2")
var subsystem_color = Color("9a25aa")
var healthy_color = Color("1bc32a")

var color_dict = {
	"burning": burning_color,
	"repairing": repair_color,
	"healthy": healthy_color
}

func _ready():
	get_node("VBoxContainer/SquadStatus").text = "HEALTHY"

func change_font_color(color):
	get_node("VBoxContainer/SquadStatus").set("custom_colors/default_color", color)

func subsystem_status(status):
	if status in color_dict:
		change_font_color(color_dict[status])
	else:
		change_font_color(subsystem_color)
	
	get_node("VBoxContainer/SquadStatus").text = status.to_upper()

func update_health(new_health):
	get_node("VBoxContainer/ProgressBar").value = new_health

func set_max_health(max_health):
	get_node("VBoxContainer/ProgressBar").max_value = max_health
