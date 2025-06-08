extends Node

@export var input_up: String
@export var input_down: String
@export var input_left: String
@export var input_right: String
@export var gear_up: String
@export var gear_down: String
@export var handbrake: String

const RAD_TO_RPM = 9.5493
const MASS = 1000
const MAX_ENGINE_TORQUE = 300.0
const MAX_RPM = 8000
const MIN_RPM = 900	 
var engine_torque
var throttle 				
var rpm = 0
var gear
var wheel_torque			

func _ready():
	pass


func _process(delta):
	pass


func player_input():
	if Input.is_action_pressed(input_up):
		throttle = 1
	else:
		throttle = 0
	# if Input.is_action_pressed(input_down):
		
	# if Input.is_action_pressed(input_left):

	# if Input.is_action_pressed(input_right):
				
	# if Input.is_action_pressed(gear_up):
		
	# if Input.is_action_pressed(gear_down):
				
	# if Input.is_action_pressed(handbrake):
		


func drivetrain():
	gaspedal()
	engine()
	pass

func gaspedal():
	pass



func engine():
	# find engine torque
	var shape = 1.5
	var curve = 1.0 - pow(abs(rpm - MAX_RPM) / MAX_RPM, shape)
	engine_torque = clamp(curve * MAX_ENGINE_TORQUE, 0, MAX_ENGINE_TORQUE)
