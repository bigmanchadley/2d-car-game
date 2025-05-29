extends Node


func _ready():
	var resume_button = find_child("resume", true, false)
	resume_button.pressed.connect(_on_resume_button_pressed)
	var exit_race_button = find_child("exit_race", true, false)
	exit_race_button.pressed.connect(_on_exit_race_button_pressed)

func _on_resume_button_pressed():
	print_debug("resume_button")
	# talks to manager
	# Unpauses the game

func _on_exit_race_button_pressed():
	print_debug("exit_race_button")

	# Talks to main
	# Runs end race protocol