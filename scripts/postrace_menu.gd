extends Node2D


signal to_main_menu_request

const RESULT_CONTAINER = preload("res://scenes/postrace_result_container.tscn")

var result # From manager

func _ready():
	var to_main_menu_button = find_child("to_main_menu_button", true, false)
	to_main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	create_display()

func create_display():
	for hud in result.keys():
		var data = result[hud]
		#var result_container = RESULT_CONTAINER.instantiate()
		var name_label = Label.new()
		var placement_label = Label.new()
		var totaltime_label = Label.new()
		var bestlap_label = Label.new()
		name_label.text = str(data["player_id"])
		placement_label.text = "someone won"
		totaltime_label.text = time_to_text(data["total_time"])
		if data["bestlap"] != null:
			bestlap_label.text = time_to_text(data["bestlap"])
		else:
			bestlap_label.text = "N/A"

		var container_target = find_child("HBoxContainer", true, false)
		container_target.get_node("VBoxContainer_names").add_child(name_label)
		container_target.get_node("VBoxContainer_placement").add_child(placement_label)
		container_target.get_node("VBoxContainer_totaltime").add_child(totaltime_label)
		container_target.get_node("VBoxContainer_bestlap").add_child(bestlap_label)
	# Get the size of the result and spawn number of HBOX with child labels
	# Update the child labels with values from result

func time_to_text(time):
	var total_centiseconds = int(time * 100)
	var seconds = total_centiseconds / 100
	var remainder = total_centiseconds % 100
	return str(seconds).pad_zeros(2) + "." + str(remainder).pad_zeros(2)


func _on_main_menu_button_pressed():
	emit_signal("to_main_menu_request")

