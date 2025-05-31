extends Node2D


signal play_requested
signal exit_requested

func _ready():
	var play_button = find_child("play_button", true, false) # path to play_button
	play_button.pressed.connect(_on_play_button_pressed)
	var exit_button = find_child("exit_button", true, false)
	exit_button.pressed.connect(_on_exit_button_pressed)





func _on_play_button_pressed():
	emit_signal("play_requested")

func _on_exit_button_pressed():
	emit_signal("exit_requested")