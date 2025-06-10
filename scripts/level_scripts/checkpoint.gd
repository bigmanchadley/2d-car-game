extends Node2D


signal checkpoint_crossed(player_id)

var p1_has_crossed
var p2_has_crossed


func _ready():
	p1_has_crossed = false
	p2_has_crossed = false

func _on_area_2d_body_entered(body:Node2D):
	if body.name == "Car":
		if body.player_id == 1 and p1_has_crossed == false:
			p1_has_crossed = true
			emit_signal("checkpoint_crossed", body.player_id)
		if body.player_id == 2 and p2_has_crossed == false:
			p2_has_crossed = true
			emit_signal("checkpoint_crossed", body.player_id)
