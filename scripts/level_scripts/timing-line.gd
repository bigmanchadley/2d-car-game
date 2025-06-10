extends Node2D


signal lap_increment(player_id)

var p1_checkpoint_increment
var p2_checkpoint_increment
var total_checkpoints


func _ready():
	p1_checkpoint_increment = 0
	p2_checkpoint_increment = 0
	total_checkpoints = get_tree().get_nodes_in_group("checkpoint").size()
	for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
		checkpoint.checkpoint_crossed.connect(checkpoint_increment)

# if player touches timing-line and passes checkpoint check, increment laps, reset checkpoints for that player_id
func _on_area_2d_body_entered(body:Node2D):
	if body.name == "Car":
		if body.player_id == 1:
			if p1_checkpoint_increment == total_checkpoints:
				p1_checkpoint_increment = 0
				emit_signal("lap_increment", body.player_id)
				reset_checkpoints(body.player_id)
		if body.player_id == 2:
			if p2_checkpoint_increment == total_checkpoints:
				p2_checkpoint_increment = 0
				emit_signal("lap_increment", body.player_id)
				reset_checkpoints(body.player_id)

func checkpoint_increment(player_id):
	if player_id == 1:
		p1_checkpoint_increment += 1
	if player_id == 2:
		p2_checkpoint_increment += 1

func reset_checkpoints(player_id):
	if player_id == 1:
		print_debug("reseting checkpoints")
		for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
			checkpoint.p1_has_crossed = false
	if player_id == 2:
		for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
			checkpoint.p2_has_crossed = false