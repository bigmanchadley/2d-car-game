extends Node2D


var time_label
var lap_label
var bestlap_label



var total_laps
var player_id_matcher # Set by manager at instantiation, 1 for player 1, and 2 for player 2
var curr_lap
var total_time
var lap_time
var bestlap

func _ready():
	bestlap = null
	total_time = 0.0
	lap_time = 0.0
	curr_lap = 1
	time_label = "00.00"
	
	time_label = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/pace
	lap_label = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/laps
	bestlap_label = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/bestlap
	bestlap_label.text = "N/A"
	var track
	var tracks = get_tree().get_nodes_in_group("track")
	if not tracks.is_empty():
		track = tracks[0]
		track.update_hud.connect(update_hud)
		total_laps = track.total_laps
	else:
		push_error("Didn't find a track")

func _process(delta):
	total_time += delta
	lap_time += delta
	time_label.text = time_to_text(lap_time)

func update_hud(player_id, current_lap):
	if player_id == player_id_matcher:
		curr_lap = current_lap
		set_lap()
		check_bestlap()
		reset_time()

func set_lap():
	lap_label.text = str(curr_lap, "/", total_laps)

func reset_time():
	lap_time = 0.0
	
func check_bestlap():
	if bestlap == null:
		bestlap = lap_time
		bestlap_label.text = time_to_text(bestlap)
	elif bestlap > lap_time:
		bestlap = lap_time
		bestlap_label.text = time_to_text(bestlap)

func time_to_text(time):
	var total_centiseconds = int(time * 100)
	var seconds = total_centiseconds / 100
	var remainder = total_centiseconds % 100
	return str(seconds).pad_zeros(2) + "." + str(remainder).pad_zeros(2)