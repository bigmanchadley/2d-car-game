extends Node2D


signal play_requested

func _ready():
	var play_button = find_child("play_button", true, false) # path to play_button
	play_button.pressed.connect(_on_play_button_pressed)






func _on_play_button_pressed():
	emit_signal("play_requested")
	print_debug("clicked play")
