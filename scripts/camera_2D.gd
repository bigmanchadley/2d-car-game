extends Node

var target
var has_target: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	has_target = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if has_target == false:
		look_for_player()
		#print_debug("looking")
	else:
		camera_follow()
		#print_debug("following")


func look_for_player():
	target = get_parent().find_child("Car", true, false)
	if target != null:
		has_target = true


func camera_follow():
	# lerp between the center of current "track node" and "cars position"
	self.position = target.global_position