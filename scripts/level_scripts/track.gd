extends Node2D




var total_laps = 2 # This will be determined at instantation in the manager, as determined by player selection in the level_menu
var p1_current_lap
var p2_current_lap

func _ready():
	p1_current_lap = 1
	p2_current_lap = 1
	var timing_line = find_child("timing-line", true, false)
	timing_line.lap_increment.connect(handle_lap)


func handle_lap(player_id):
	if player_id == 1:
		p1_current_lap += 1
	if player_id == 2:
		p2_current_lap += 1

	if p1_current_lap > total_laps or p2_current_lap > total_laps:
		print_debug("Player ", player_id, " wins!")









# Ready
	# Count Number of Checkpoints - Give to timing-line


# From Parent/outside
	# Receive number of laps selected by player in Level Menu
	# Receive number of players





