extends WindowDialog

signal option(id)

func _ready():
	pass


func _on_PopupMenu_id_pressed(id):
	emit_signal("option", id)



func _on_CrashPopup_about_to_show():
	get_node("PopupMenu").show()
