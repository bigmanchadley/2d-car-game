extends Node2D


# Called when the node enters the scene tree for the first time.

var currentlap
var bestlap
var lastlap

var trigger
var total_time = 0.0
var start_timer = false
var best_time = 99.0
var display_time = "00:00"


func _ready():
	currentlap = $TimeLabel
	bestlap = $BestLap
	lastlap = $LastLap

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if start_timer:
		total_time += delta
		var total_centiseconds = int(total_time * 100)

		var seconds = total_centiseconds / 100
		var remainder = total_centiseconds % 100
		display_time = str(seconds).pad_zeros(2) + " : " + str(remainder).pad_zeros(2)
		currentlap.text = display_time


func _on_area_2d_body_exited(body):
	if body.get_name() == "Car":
		total_time = 0.0
		start_timer = true



func _on_area_2d_body_entered(body):
	if body.get_name() == "Car":
		if total_time < best_time and total_time >= 20.0:
			bestlap.text = display_time
			best_time = total_time
			lastlap.text = display_time
		#lastlap.text = display_time
		start_timer = false

	pass # Replace with function body.
