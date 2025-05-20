extends Node2D

# scenes
const CAR_SCENE = preload("res://scenes/car.tscn")
const COUNTDOWN_SCENE = preload("res://scenes/countdown.tscn")
const STOPWATCH_SCENE = preload("res://scenes/stopwatch.tscn")
const CAMERA_SCENE = preload("res://scenes/camera_2d.tscn")
# level scenes
var level # Path to selected level scene
var track # Instance of level
# assets
const CAR_RED = preload("res://art/car_assets/redcar.png")
const CAR_BLACK = preload("res://art/car_assets/blackcar.png")
const CAR_YELLOW = preload("res://art/car_assets/yellowcar.png")



# Instantiate
	#Players
var p1
var p2
var p3

# Derived from main. Assigned at instantiation
var p1_sprite_choice
var p2_sprite_choice
var p3_sprite_choice
	# Cameras
var cam1
	#Countdown
var countdown
	#stopwatch (includes laptimers) # desperately needs to be decoupled or made intelligent (give locations to children somehow)
var stopwatch



# Derived from level scene "locations". Assigned at instantiation
var starting_position_1
var starting_position_2
var starting_position_3


# Derived from main.gd. Assigned at instantiation
var player_count
# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_level()
	set_start_locations()
	spawn_players()
	spawn_camera()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func start_countdown():
	if countdown != null:
		countdown.queue_free()
		countdown = null
	countdown = COUNTDOWN_SCENE.instantiate()
	countdown.position = $locations/countdown_location.position
	add_child(countdown)

func start_laps():
	if stopwatch != null:
		stopwatch.queue_free()
		stopwatch = null
	stopwatch = STOPWATCH_SCENE.instantiate()
	stopwatch.position = $locations/stopwatch_location.position # This is still giga hardcoded since there is only 1 stopwatch location for 3 labels
	add_child(stopwatch)

func spawn_players():

	if player_count >= 1:
		p1 = CAR_SCENE.instantiate()
		p1.transform = starting_position_1
		var p1_car = p1.get_node("Car")
		var p1_sprite = p1_car.get_node("Sprite2D")
		p1_sprite.texture = p1_sprite_choice
		p1_car.input_up = "P1_Forward"
		p1_car.input_down = "P1_Backward"
		p1_car.input_left = "P1_Left"
		p1_car.input_right = "P1_Right"
		add_child(p1)
	if player_count >= 2:
		p2 = CAR_SCENE.instantiate()
		p2.name = "Player2"
		p2.transform = starting_position_2
		var p2_car = p2.get_node("Car")
		var p2_sprite = p2_car.get_node("Sprite2D")
		p2_sprite.texture = p2_sprite_choice
		p2_car.input_up = "P2_Forward"
		p2_car.input_down = "P2_Backward"
		p2_car.input_left = "P2_Left"
		p2_car.input_right = "P2_Right"
		add_child(p2)



func spawn_camera():
	cam1 = CAMERA_SCENE.instantiate()
	add_child(cam1)

func spawn_level():
	track = level.instantiate()
	add_child(track)

func set_start_locations():
	starting_position_1 = track.find_child("start_pos_1").transform
	starting_position_2 = track.find_child("start_pos_2").transform
	starting_position_3 = track.find_child("start_pos_3").transform