extends Node2D

var starting_position_1 = Vector2(-245, -430)
var starting_position_2 = Vector2(-245, -400)
# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_players()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func spawn_players():
	var car_scene = preload("res://car.tscn")
	var car_color = preload("res://art/car_colors/blackcar.png")

	var player1 = car_scene.instantiate()
	player1.position = starting_position_1
	var car1 = player1.get_node("Car")
	car1.input_up = "P1_Forward"
	car1.input_down = "P1_Backward"
	car1.input_left = "P1_Left"
	car1.input_right = "P1_Right"
	add_child(player1)

	var p2 = car_scene.instantiate()
	p2.position = starting_position_2
	var p2_car = p2.get_node("Car")
	var p2_sprite = p2_car.get_node("Sprite2D")
	p2_sprite.texture = car_color
	p2_car.input_up = "P2_Forward"
	p2_car.input_down = "P2_Backward"
	p2_car.input_left = "P2_Left"
	p2_car.input_right = "P2_Right"
	add_child(p2)


func _on_add_drop_player_pressed():
	pass # Replace with function body.
