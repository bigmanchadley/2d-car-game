extends Node2D

# Background Image
const BACKGROUND = preload("res://art/level_assets/test_background.png")

# Scenes
	# Manager
const MANAGER = preload("res://scenes/manager.tscn")
	# Camera
const CAMERA = preload("res://scenes/camera_2d.tscn")
	# UI
const MAIN_MENU = preload("res://scenes/main_menu.tscn")
const LEVEL_MENU = preload("res://scenes/level_menu.tscn")

# Background
var background
# Manager
var manager
# Camera
var camera_1
# Main Menu
var main_menu
var main_menu_canvas
# Level Menu
var level_menu
var level_menu_canvas

# Variables
var player_count = 1
var selected_level = preload("res://scenes/tracks/island_forward.tscn")
var p1_car_choice
var p2_car_choice
var p3_car_choice

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load the Background
	background = Sprite2D.new()
	background.texture = BACKGROUND
	add_child(background)
	# Load the Camera
	#camera_1 = CAMERA.instantiate()
	#add_child(camera_1)

	# Instantiate all UI, then manage visibility via signal
	main_menu = MAIN_MENU.instantiate()
	main_menu.visible = true
	main_menu.play_requested.connect(play_requested)
	main_menu_canvas = main_menu.get_node("main_menu_canvas")
	add_child(main_menu)

	level_menu = LEVEL_MENU.instantiate()
	level_menu.visible = true
	level_menu_canvas = level_menu.get_node("level_menu_canvas")
	level_menu.level_menu_back_requested.connect(load_main_menu)
	level_menu.level_button_requested.connect(set_selected_level)
	level_menu.set_player_count.connect(set_player_count)
	level_menu.start_button_requested.connect(start_race_requested)
	level_menu.set_p1_car.connect(set_p1_car)
	level_menu.set_p2_car.connect(set_p2_car)
	level_menu.set_p3_car.connect(set_p3_car)
	add_child(level_menu)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_player_count(pc):
	player_count = pc
func get_player_count():
	return player_count

func set_selected_level():
	pass
func get_selected_level():
	return selected_level



func play_requested():
	print_debug("made it to main")
	# Load level selector
	load_level_menu()


func load_main_menu():
	# Visible = true
	main_menu_canvas.visible = true
	level_menu_canvas.visible = false

func load_level_menu():
	main_menu_canvas.visible = false
	level_menu_canvas.visible = true

func set_p1_car(texture):
	p1_car_choice = texture
func get_p1_car():
	return p1_car_choice
func set_p2_car(texture):
	p2_car_choice = texture
func get_p2_car():
	return p2_car_choice
func set_p3_car(texture):
	p3_car_choice = texture
func get_p3_car():
	return p3_car_choice


func start_race_requested():
	# Get variables from level_menu
	# Number of players
	# Cars selected for each player
	# Level selected

	# For now just start the game with the island level

	main_menu_canvas.visible = false
	level_menu_canvas.visible = false
	manager = MANAGER.instantiate()
	manager.player_count = get_player_count()
	manager.level = get_selected_level()
	manager.p1_sprite_choice = get_p1_car()
	manager.p2_sprite_choice = get_p2_car()
	manager.p3_sprite_choice = get_p3_car()
	add_child(manager)



# Method
# All menu scenes are loaded at launch
# Visibility set to true/false based on button presses
# Each menu has its own script for Buttons, but all button presses are sent to main.gd

# Structure
# Main
	# Scene - Runs a background and holds a Node2D "main" that will be the root of all other nodes
	# Script - Preloads all other menu scenes (Main Menu, Level Menu)
	
	# Main Menu
		# Scene - Holds buttons (Play, Settings, Exit)
		# Script
			# Buttons 
				# Play - Switches to level select menu
				# Settings - (if implimented) Change keybinds, videos settings
				# Exit - Closes game
	
	# Level Menu
		# Scene - Holds Buttons (For each level, and Back)
		# Script
			# Buttons
				# The level buttons need to be populated for each track in a robust way
				# Back - Goes back to the Main Menu

	# Car Menu - Maybe Combine with Level Menu
		# Scene - Holds Buttons (Set Player Amount, and car selector for number of players)		
		# Script
			# Buttons
				# Number of Players +-: Cycles through 1-3 Players AND add/remove the Car Selector buttons
				# Car Selector: Cycle through car options
				# Back - Goes back to the Level Menu

	# In Game Menu - Press Esc
		# Scene - Holds buttons (Resume, Quit Race)
		# Script
			# Buttons
				# Resume, Unpauses the game, menu visibility disappears
				# Quit Race: Unloads the race specific nodes, Goes to Main Menu
