extends Node2D


signal play_requested

# Called when the node enters the scene tree for the first time.
func _ready():
	var play_button = find_child("play_button", true, false) # path to play_button
	play_button.pressed.connect(_on_play_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_play_button_pressed():
	emit_signal("play_requested")
	print_debug("clicked play")
