extends Node2D


signal level_menu_back_requested
signal level_button_requested
signal start_button_requested
signal set_player_count(player_count)
signal set_p1_car(texture)
signal set_p2_car(texture)
signal set_p3_car(texture)

var player_count = 1
var p1_car_button
var p2_car_button
var p3_car_button

const CAR_RED = preload("res://art/car_assets/redcar.png")
const CAR_BLACK = preload("res://art/car_assets/blackcar.png")
const CAR_YELLOW = preload("res://art/car_assets/yellowcar.png")

const CAR_RED_ICON = preload("res://art/car_assets/icons/redcar_icon.png")
const CAR_BLACK_ICON = preload("res://art/car_assets/icons/blackcar_icon.png")
const CAR_YELLOW_ICON = preload("res://art/car_assets/icons/yellowcar_icon.png")

const CAR_SELECTOR = [CAR_RED, CAR_BLACK, CAR_YELLOW]
const CAR_ICON_SELECTOR = [CAR_RED_ICON, CAR_BLACK_ICON, CAR_YELLOW_ICON]
var p1_car_index = 0
var p2_car_index = 1
var p3_car_index = 2



func _ready():
	
	var back_button = find_child("back_button", true, false)
	back_button.pressed.connect(_on_back_button_pressed)

	var level_button = find_child("level_button", true, false)
	level_button.pressed.connect(_on_level_button_pressed)

	var start_button = find_child("start_button", true, false)
	start_button.pressed.connect(_on_start_button_pressed)

	var add_drop_button = find_child("add_drop", true, false)
	add_drop_button.pressed.connect(_on_add_drop_button_pressed)

	p1_car_button = find_child("p1_car_select", true, false)
	p1_car_button.pressed.connect(_on_p1_car_button_pressed)
	p1_car_button.icon = CAR_ICON_SELECTOR[p1_car_index]
	emit_signal("set_p1_car", CAR_SELECTOR[p1_car_index])

	p2_car_button = find_child("p2_car_select", true, false)
	p2_car_button.pressed.connect(_on_p2_car_button_pressed)
	p2_car_button.icon = CAR_ICON_SELECTOR[p2_car_index]
	emit_signal("set_p2_car", CAR_SELECTOR[p2_car_index])

	p3_car_button = find_child("p3_car_select", true, false)
	p3_car_button.pressed.connect(_on_p3_car_button_pressed)
	p3_car_button.icon = CAR_ICON_SELECTOR[p3_car_index]
	# Consider emitting CAR_SELECTOR[Index] for each car in ready()
	emit_signal("set_p3_car", CAR_SELECTOR[p3_car_index])


	player_count_ui()

func _process(delta):
	pass
func _on_back_button_pressed():
	emit_signal("level_menu_back_requested")
	
func _on_level_button_pressed():
	# should give a path to the currently selected level
	emit_signal("level_button_requested")

func _on_start_button_pressed():
	emit_signal("start_button_requested")

func _on_add_drop_button_pressed():
	if player_count == 3:
		player_count = 1
	else:
		player_count += 1
	emit_signal("set_player_count", player_count)
	player_count_ui()

func player_count_ui():
	#Add button # Add button # remove two buttons
	# or just set to visible or invisble
	if player_count >= 2:
		p2_car_button.visible = true
	else:
		p2_car_button.visible = false
	if player_count >= 3:
		p3_car_button.visible = true
	else:
		p3_car_button.visible = false

func _on_p1_car_button_pressed():
	if p1_car_index == 2:
		p1_car_index = 0
	else:
		p1_car_index += 1
	p1_car_button.icon = CAR_ICON_SELECTOR[p1_car_index]
	emit_signal("set_p1_car", CAR_SELECTOR[p1_car_index])
func _on_p2_car_button_pressed():
	if p2_car_index == 2:
		p2_car_index = 0
	else:
		p2_car_index += 1
	p2_car_button.icon = CAR_ICON_SELECTOR[p2_car_index]
	emit_signal("set_p2_car", CAR_SELECTOR[p2_car_index])
func _on_p3_car_button_pressed():
	if p3_car_index == 2:
		p3_car_index = 0
	else:
		p3_car_index += 1
	p3_car_button.icon = CAR_ICON_SELECTOR[p3_car_index]
	emit_signal("set_p3_car", CAR_SELECTOR[p3_car_index])
# Add/Drop Button
# Populates the UI with a new button. At 3, if clicked again, reverts to 1
	# Also changes the player_count variable accordingly.
# The New button has a picture of the default car color
# Clicking the button cycles through the available colors
