extends Node2D

# signals
signal exit_race_button_requested


# scenes
const CAR_SCENE = preload("res://scenes/car.tscn")
const COUNTDOWN_SCENE = preload("res://scenes/countdown.tscn")
const STOPWATCH_SCENE = preload("res://scenes/stopwatch.tscn")
const CAMERA_SCENE = preload("res://scenes/camera_2d.tscn")
const INGAME_MENU = preload("res://scenes/ingame_menu.tscn")
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
var listen_cam
	# Countdown
var countdown
	# stopwatch (includes laptimers) # desperately needs to be decoupled or made intelligent (give locations to children somehow)
var stopwatch



# Derived from level scene "locations". Assigned at instantiation
var starting_position_1
var starting_position_2
var starting_position_3

# In game manu
var igm
var igm_canvas

# Derived from main.gd. Assigned at instantiation
var player_count
# Called when the node enters the scene tree for the first time.
func _ready():
	setup()
	create_ingame_menu()
	#spawn_level()
	#set_start_locations()
	#spawn_players()
	#spawn_camera()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	universal_input()
	pass

func universal_input():
	# Open ingame menu
	if Input.is_action_just_pressed("Escape"):
		toggle_ingame_menu()

func create_ingame_menu():
	igm = INGAME_MENU.instantiate()
	igm_canvas = igm.get_node("CanvasLayer")
	igm_canvas.visible = false
	igm.resume_button_requested.connect(resume_button)
	igm.exit_race_button_requested.connect(exit_race_button)
	add_child(igm)

func toggle_ingame_menu():
	igm_canvas.visible = !igm_canvas.visible
	# if visible == true then pause

func resume_button():
	# Need to add pause/resume functionality
	igm_canvas.visible = false

func exit_race_button():
	emit_signal("exit_race_button_requested")

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

func spawn_players(p_node):
	if player_count >= 1:
		p1 = CAR_SCENE.instantiate()
		p1.transform = starting_position_1
		var p1_car = p1.get_node("Car")
		var p1_sprite = p1_car.get_node("Sprite2D")
		p1_sprite.texture = p1_sprite_choice
		p1_car.player_id = 1
		p1_car.input_up = "P1_Forward"
		p1_car.input_down = "P1_Backward"
		p1_car.input_left = "P1_Left"
		p1_car.input_right = "P1_Right"
		p_node.add_child(p1)
		listen_cam = CAMERA_SCENE.instantiate()
		p1_car.add_child(listen_cam)
	if player_count >= 2:
		p2 = CAR_SCENE.instantiate()
		p2.name = "Player2"
		p2.transform = starting_position_2
		var p2_car = p2.get_node("Car")
		var p2_sprite = p2_car.get_node("Sprite2D")
		p2_sprite.texture = p2_sprite_choice
		p2_car.player_id = 2
		p2_car.input_up = "P2_Forward"
		p2_car.input_down = "P2_Backward"
		p2_car.input_left = "P2_Left"
		p2_car.input_right = "P2_Right"
		p_node.add_child(p2)



func spawn_camera(p_node):
	cam1 = CAMERA_SCENE.instantiate()
	p_node.add_child(cam1)

func spawn_level(p_node):
	track = level.instantiate()
	p_node.add_child(track)

func set_start_locations():
	starting_position_1 = track.find_child("start_pos_1").transform
	starting_position_2 = track.find_child("start_pos_2").transform
	starting_position_3 = track.find_child("start_pos_3").transform



func setup():
	# Always run for 1 Player
	var v_container := VBoxContainer.new()
	var sv_container := SubViewportContainer.new()
	var sv := SubViewport.new()
	v_container.name = "VBoxContainer"
	sv_container.name = "SubViewportContainer"
	sv.name = "SubViewport"
	add_child(v_container)
	v_container.add_theme_constant_override("separation", 0)
	v_container.add_child(sv_container)
	sv_container.add_child(sv)
	var size_y = 1080/player_count
	sv.size = Vector2(1920, size_y)
	



	spawn_level(sv)
	set_start_locations()
	spawn_players(sv)
	spawn_camera(sv)

	var p1_sv_world = sv.world_2d
	# For each player other than 1
	for i in range(1, player_count):
		var affix = str(i)
		sv_container = SubViewportContainer.new()
		sv = SubViewport.new()
		sv_container.name = "SubViewportContainer" + affix
		sv.name = "SubViewport" + affix
		sv.world_2d = p1_sv_world

		v_container.add_child(sv_container)
		sv_container.add_child(sv)
		sv.size = Vector2(1920, 540)
		spawn_camera(sv)

	
	# Add a Remote transform to each player/car node
	# Find all players that exist
	var players := {
		0: {
			viewport = $"VBoxContainer/SubViewportContainer/SubViewport",
			camera = $"VBoxContainer/SubViewportContainer/SubViewport/Camera2D",
			player = $VBoxContainer/SubViewportContainer/SubViewport/Player1/Car,
		},
		1: {
			viewport = $"VBoxContainer/SubViewportContainer1/SubViewport1",
			camera = $"VBoxContainer/SubViewportContainer1/SubViewport1/Camera2D",
			player = $VBoxContainer/SubViewportContainer/SubViewport/Player2/Car,		
		},
		# 2: {
		# 	viewport = $"VBoxContainer/SubViewportContainer2/SubViewport2",
		# 	camera = $"VBoxContainer/SubViewportContainer2/SubViewport2/Camera2D",
		# 	player = $VBoxContainer/SubViewportContainer/SubViewport/Player2/Car,		
		# }		
	}
	for i in range(player_count):
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = players[i].camera.get_path()
		players[i].player.add_child(remote_transform)

