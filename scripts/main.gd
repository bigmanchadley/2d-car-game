extends Node2D


const MAIN_MENU = preload("res://scenes/main_menu.tscn")
const LEVEL_MENU = preload("res://scenes/level_menu.tscn")

var main_menu
var level_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	# Instantiate all UI, then manage visibility via signal
	main_menu = MAIN_MENU.instantiate()
	add_child(main_menu)
	main_menu.play_requested.connect(play_requested)

	level_menu = LEVEL_MENU.instantiate()
	add_child(level_menu)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func play_requested():
	print_debug("made it to main")
	# Load level selector
	load_level_menu()
	pass


func load_main_menu():
	# Visible = true
	pass

func load_level_menu():
	# Visibile = true
	remove_child(main_menu)
	pass


