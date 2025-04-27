extends Node


@onready var countdown_label = $Label

const total_countdown_time = 3.9
var time_left: float

# Called when the node enters the scene tree for the first time.
func _ready():
	time_left = total_countdown_time
	countdown_label.text = str(total_countdown_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_left -= delta
	if time_left > 1:
		countdown_label.text = str(int(time_left))
	else:
		countdown_label.text = "GO!"
		countdown_label.modulate.a -= delta

	if countdown_label.modulate.a < 0:
		queue_free()
