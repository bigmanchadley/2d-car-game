extends Node2D

signal update_hud(player_id, current_lap)
signal race_completed(result)



var total_laps = 1 # This will be determined at instantation in the manager, as determined by player selection in the level_menu
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
		emit_signal("update_hud", player_id, p1_current_lap)
	if player_id == 2:
		p2_current_lap += 1
		emit_signal("update_hud", player_id, p2_current_lap)

	if p1_current_lap > total_laps or p2_current_lap > total_laps:
		get_result()

func get_result():
	var result = {}
	for playerhud in get_tree().get_nodes_in_group("playerHUD"):
		result[playerhud] = {
			"player_id": playerhud.player_id_matcher,
			"total_time": playerhud.total_time,
			"bestlap": playerhud.bestlap
		}	
	emit_signal("race_completed", result)







# Track script
	# Receives
		# Calculated laps from received player ID
	# Updates
		# sends laps to player HUDs





