extends AudioStreamPlayer2D

#Get rpms
var car_node

var prev_rpm

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	if get_parent().is_in_group("cars"):
		car_node = get_parent()
	else:
		printerr("Car node is null. get_parent() did not find a parent in group 'cars'")
	stream.loop = true
	playing = true
	prev_rpm = 0
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if car_node != null:

		#print_debug("rpm:	", car_node.rpm)
		pitch_scale = 1 + car_node.rpm/3000.0
		#volume_db = car_node.gear
		#print_debug("pitch_scale:	", pitch_scale)
		#print_debug("gear:	", car_node.gear)
	pass
