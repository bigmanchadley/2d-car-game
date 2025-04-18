extends CharacterBody2D


@export var input_up: String
@export var input_down: String
@export var input_left: String
@export var input_right: String

##### Constants #####
const MAX_SPEED = 300
const POWER = 300


##### Variables #####
var l = 0.0
var r = 0.0

var turn_left = Vector2(0,0)
var turn_right = Vector2(0,0)
var steer_dir 
var accel_dir
var gear
var torque
var prev_velocity
var force_addition = Vector2.ZERO
var dynamic_etr
var dynamic_etr_left
var dynamic_etr_right
var new_etr
var maintained_vel = Vector2(0,0)
var transferred_vel
var medial_vel = Vector2(0,0)
var lateral_vel
var lateral_friction
var is_drifting = false
var is_accelerating = false
var is_braking
var brake_friction


var traction = 1.0
var rot_dir
var rot_momentum = 0.0
const MAX_ROT_TORQUE = 10500 # POWER * Max turning radius degree: 300 * 35


###################################### START MAIN ############################################
func _physics_process(delta):
	prev_velocity = velocity
	medial_vel
	
	gearbox()
	torque_calculation()
	player_input(delta)
	acceleration(delta)
	steering(delta)
	
	queue_redraw()

	move_and_slide()

####################################### END MAIN ###############################################
####################################### DEBUGGER ###############################################
func _draw():
	
# 	draw_line(Vector2.ZERO, global_transform.basis_xform_inv(steer_dir) * 50, Color(0, 1, 0), 3)
	# #draw_line(Vector2.ZERO, turn_left * 50, Color(1, 0, 0), 2)
	# #draw_line(Vector2.ZERO, turn_right * 50, Color(1, 0, 0), 2)
	# #draw_line(Vector2.ZERO, accel_dir_debug * 50, Color(0, 0, 1), 2)
	# draw_line(Vector2.ZERO, global_transform.basis_xform_inv(dynamic_etr_left) * 50, Color(1,0,0), 4)
	# draw_line(Vector2.ZERO, global_transform.basis_xform_inv(dynamic_etr_right) * 50, Color(1,0,0), 4)
	# #draw_line(Vector2.ZERO, new_etr * 50, Color(0,0,1), 4)
	#draw_line(Vector2.ZERO, global_transform.basis_xform_inv(velocity) * 2, Color(1,1,1), 5) # white
	# #draw_line(Vector2.ZERO, global_transform.basis_xform_inv(accel_dir) * 50, Color(1,0,1), 4) # pink
	draw_line(Vector2.ZERO, global_transform.basis_xform_inv(force_addition) * 50, Color(0,0,1), 3) #blue
	# #draw_line(Vector2.ZERO, global_transform.basis_xform_inv(maintained_vel) * 2, Color(1,1,0), 4) #yellow
	# #draw_line(Vector2.ZERO, global_transform.basis_xform_inv(transferred_vel) * 2, Color(0,1,1), 3) #teal
	# #draw_line(Vector2.ZERO, global_transform.basis_xform_inv(perp_vector) * 52, Color(0,0,1), 3) #blue
	#draw_line(Vector2.ZERO, global_transform.basis_xform_inv(medial_vel) * 2, Color(0.5,0.5,1), 3) #light blue
	#draw_line(Vector2.ZERO, global_transform.basis_xform_inv(lateral_vel) * 2, Color(1,0.5,0.5), 3) #pink
	#draw_line(Vector2.ZERO + Vector2.UP * 20, global_transform.basis_xform_inv(sign(rot_dir) * Vector2.RIGHT.rotated(rotation)) * 52, Color(0,0,1), 3) #blue
	#pass

	# NOTES
	# The draw_line apparently does a rotation pass or something. So I have to pass an unrotated value or there will be a mismatch (double rotation)


################################## Function Declarations ########################################
#################################################################################################
func gearbox():
	gear = ceil((medial_vel.length() / MAX_SPEED) * 6) # 6 is number of gears
	if gear > 6:
		gear = 6
	if gear < 1:
		gear = 1

#################################################################################################
func torque_calculation():
	torque = POWER / gear

#################################################################################################
func player_input(delta):
	# Gather Inputs: Forward/Backward
	var fwd_dir = Vector2.UP.rotated(rotation)
	
	var fwd_input
	var bwd_input
	var brake_check
	if Input.is_action_pressed(input_up):
		fwd_input = Vector2(0, -1)
	else:
		fwd_input = Vector2(0,0)

	if Input.is_action_pressed(input_down):
		bwd_input = Vector2(0, 1)
		brake_check = true
	else:
		bwd_input = Vector2(0,0)
		brake_check = false
	# Store Acceleration direction
	accel_dir = (fwd_input + bwd_input).rotated(rotation).normalized()

	# Gather Inputs: Left/Right
	turn_left = Vector2(0,0)
	turn_right = Vector2(0,0)

	if Input.is_action_pressed(input_left):
		l = min(l + delta, 1.0) # this clamps 0 and 1
		turn_left = Vector2(-0.573576 * l, -0.819152).rotated(rotation) # up to 35 degree angle (aproximately)
		$Sprite2D.frame = 1
	else:
		l = 0
		
	if Input.is_action_pressed(input_right):
		r = min(r + delta, 1.0) # this clamps 0 and 1
		turn_right = Vector2(0.573576 * r, -0.819152).rotated(rotation) # 35 degrees
		$Sprite2D.frame = 2
	else:
		r = 0
	var reverse_correct = sign(fwd_dir.dot(velocity))

	steer_dir = (turn_left + turn_right).normalized() * reverse_correct
	if steer_dir == Vector2(0,0):							
		steer_dir = fwd_dir

	# Car Sprite Switcher #######################################################
	if steer_dir == fwd_dir:
		$Sprite2D.frame = 0
	#############################################################################
	# Braking #############################################################
	
	if brake_check:
		var alignment = velocity.normalized().dot(fwd_dir) # 0 to 1
		#print_debug("brake_alignment:	", alignment)
		if alignment > 0:
			is_braking = true

		else:
			is_braking = false
	else:
		is_braking = false

	if is_braking:
		brake_friction = 0.99
	else:
		brake_friction = 1.0

	#print_debug("is_braking:	", is_braking)
	#############################################################################

#################################################################################################
func acceleration(delta):

	# Force_addition = accel_dir * torque * traction
		# gear will be changed to be based off of medial velocity and so change torque

	force_addition = (accel_dir * torque * traction * delta) * brake_friction
	if force_addition != Vector2(0,0):
		is_accelerating = true
	else:
		is_accelerating = false
	if is_braking:
		is_accelerating = false
		force_addition *= 0.2



#################################################################################################
func steering(delta):
	# Least Dependant
	var fwd_dir = Vector2.UP.rotated(rotation)
	var vel_dir = velocity.normalized()
	var vel_mag = velocity.length()
		



	# START HERE
	var new_etr_degree = clampf((45 * (1- prev_velocity.length()/MAX_SPEED)), 5, 45) # range of 5 to 35
	var new_etr_radians = deg_to_rad(new_etr_degree)


	dynamic_etr_left = Vector2(-sin(new_etr_radians), -cos(new_etr_radians)).rotated(rotation)
	dynamic_etr_right = Vector2(sin(new_etr_radians), -cos(new_etr_radians)).rotated(rotation)

	var steer_degree = rad_to_deg(steer_dir.angle_to(Vector2.UP.rotated(rotation)))
	var steer_degree_abs = abs(steer_degree)
	if steer_degree_abs == 180:
		steer_degree_abs = 0


	# var grip = 1
	# if steer_degree_abs > new_etr_degree:
	# 	grip = new_etr_degree/steer_degree_abs # don't need to worry about divide by 0 because steer_degree is only > new_etr_degree if steer_degree is non-zero


	var medial_speed = velocity.dot(fwd_dir)
	lateral_vel = (velocity - medial_speed * fwd_dir)
	medial_vel = medial_speed * fwd_dir

	var lateral_mag = lateral_vel.length()
	var lateral_dir = lateral_vel.normalized()

	
	# Lateral friction: The controlling variable that allows drifting
		# Culmination of: lateral_vel.length(), velocity.length()?, is_accelerating, traction_vector?

	# How does car start to slide?
	# when the lateral_vel.length() is > the traction_vector (Doesnt need to be a )
		# consider subtracting the traction size from the lateral vel constantly so there isn't a surge when traction is broken, it bleeds in
	var accel_factor = 0.997 # if not accelerating the friction value is reduced (friction increases)
	if is_accelerating:
		accel_factor = 1.0 # if accelerating the friction value stays at 100%

	var friction_ratio = lateral_mag / 100
	var friction_weight = clamp(friction_ratio, 0.0, 1.0)

	lateral_friction = lerp(0.9, 0.99, friction_weight) * accel_factor
	#print_debug(lateral_friction)

	lateral_vel *= lateral_friction

	#############################################################################
	# Medial Friction ###########################################################
		# This could probably be simplified
	var drag_coefficient = 0.02
	var rolling_friction = 0.9999 # WIP
	var drag_ratio = clamp(velocity.length_squared() / (MAX_SPEED * MAX_SPEED), 0.0, 0.1)
	var air_friction = 1.0 - drag_ratio * drag_coefficient
	var medial_friction = rolling_friction * air_friction * brake_friction
	#############################################################################
	# Velocity ##################################################################
		# clamp the velocity probably
	#print_debug("air_friction:		", air_friction)
	#print_debug("medial_friction:	", medial_friction)
	velocity = (lateral_vel) + (medial_vel * medial_friction) + force_addition
	#print_debug("velocity length:	", velocity.length())
	#############################################################################
	# ROTATION TO DO LIST #######################################################
	
	# rotational momentum can't really exist unless the car is sliding
		# So, either use states, or replicate states doing some turn rate to velocity ratio to
			# dictate if rot_momentum is used or just a constant turn radius is used.
		# ALSO: Rot_momentum needs two things (probably 2)
			# Greater angular_friction at low velocity AND/OR greater angular_friction at Low rot_momentum
	# Okay, I think rot_torque/speed should be low high low from 0 to 90 degrees, determined by velocity alignment to fwd, 45, perpindicular
		# Also relative to velocity, but angular friction might be able to handle that part
	#############################################################################
	# Angular Friction ##########################################################
	var speed_ratio = clamp(velocity.length() / 200, 0.0, 1.0)
	var alignment = abs(velocity.normalized().dot(fwd_dir)) # 0 to 1
	if velocity == Vector2(0,0):
		alignment = 1
	#print_debug("alignment:	", alignment)


	# Less friction at higher speeds
	# Consider using 0.1 at the lerp min
		# More angular friction at low speed - May need to change but certainly works as a bandaid
	var angular_friction = lerp(0.1, 0.99, speed_ratio * (1.0 - alignment))
	#############################################################################
	# Alignment Force ###########################################################
	var misalignment = vel_dir.cross(fwd_dir)
	traction = lerp(0.5, 1.0, alignment)
	var aligning_force = traction * -misalignment

	#print_debug("aligning_force: ", aligning_force)
	#print_debug("traction:	", traction)
	#print_debug("misalignment:	", misalignment)
	#############################################################################
	# Rotation Momentum #########################################################
	rot_dir = -sign(steer_degree)
	var rot_speed = 4
	# rot_traction: When aligned traction = 1 down to 0.5 at 90 degree slide
					# however, when velocity = 0, rot_traction needs to = 0
	var rot_traction = traction * clamp(vel_mag/100, 0.0, 1.0)
	#print_debug("rot_traction:	", rot_traction)
	# Replace the 4 with a rot_speed or rot torque. Consider variability vs constant
	# May want rot_speed to be a value that increases with velocity? Or torque or sudden change in velocity?
	rot_momentum += (aligning_force + rot_speed * rot_traction * rot_dir) * delta
	rot_momentum *= pow(angular_friction, delta)
	rot_momentum = clamp(rot_momentum, -4, 4)
	# print_debug("alignment: 	", alignment)
	# print_debug("weight:	", speed_ratio * (1.0 - alignment))
	# print_debug("angular_friction:	", angular_friction)
	print_debug("rot_momentum:	", rot_momentum)
	#############################################################################
	rotation += rot_momentum * delta

	# Working Code
	# var car_length = 34
	# var d = velocity.length() * delta # maybe shouldn't use magnitude?
	# if steer_degree != 0:
	# 	var real_turn_radius = car_length/sin(abs(steer_dir.angle_to(Vector2.UP.rotated(rotation))))
	# 	var turn_angle = d/real_turn_radius
	# 	rotation += turn_angle * sign(-steer_degree)


	return null



#################################################################################################


############## STRUCTURE TEMPLATE #################

# Constants
# Variables

# _Physics Process ()
	# Gear Function
	# Torque Function
	# Player Input
	# Acceleration
	# Steering
	# MoveAndSlide
	## Draw Debugger ##

##Declarations##
# Gear Function
# Torque Function
# Player Input
# Acceleration
# Steering



# Things to change
	# Current Dynamic Steering uses something that could just be lerp(). The lerp function would allow for more and simpler implimentation of fine tuning the steering speed.
	# Current Turn angle is actually 55 degrees. Shhould be 35
	# If im going backwards and press forwards, the deceleration should be using gear 1, not the current gear
		# Example, if im going speed 300 backwards and press forwards, the torque applied should not be that of gear 6, but gear 1 
