extends ProgressBar


func init(starting_value):
	self.max_value = starting_value
	self.value = starting_value

func update_health(new_value):
	self.value = new_value

func update_position(ship_position):
	self.set_global_position(ship_position)
