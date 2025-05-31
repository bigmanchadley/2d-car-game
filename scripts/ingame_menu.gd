extends Node

signal resume_button_requested
signal exit_race_button_requested

func _ready():
	var resume_button = find_child("resume", true, false)
	resume_button.pressed.connect(_on_resume_button_pressed)
	var exit_race_button = find_child("exit_race", true, false)
	exit_race_button.pressed.connect(_on_exit_race_button_pressed)

func _on_resume_button_pressed():
	emit_signal("resume_button_requested")

	# talks to manager
	# Unpauses the game

func _on_exit_race_button_pressed():
	emit_signal("exit_race_button_requested")

	# Talks to main THROUGH manager
	# Runs end race protocol
	
	# Manager runs end race protocol
	# Manager Lets main know if needed?
		# Presumably to toggle menu visibility