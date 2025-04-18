extends CharacterBody2D


@export var input_up: String
@export var input_down: String
@export var input_left: String
@export var input_right: String

##### Constants #####
const MAX_SPEED = 300
const POWER = 300


##### Variables #####
var fwd_dir: Vector2
var alignment: float
var gear
var torque
var brake_check: bool
var is_braking: bool
var brake_friction: float
var rot_dir: float


# Localize these variables?
var fwd_input
var bwd_input
var turn_left 
var turn_right
var accel_dir

# Put in on ready?
var force_addition = Vector2.ZERO
var is_accelerating = false
var traction = 1.0
var rot_momentum = 0.0
var medial_vel = Vector2(0,0)
var lateral_vel = Vector2(0,0)


###################################### START MAIN ############################################
func _physics_process(delta):
	update_variables()
	player_input()
	acceleration(delta)
	steering(delta)
	
	queue_redraw()

	move_and_slide()

####################################### END MAIN ###############################################
####################################### DEBUGGER ###############################################
func _draw():
	
	#draw_line(Vector2.ZERO, global_transform.basis_xform_inv(steer_dir) * 50, Color(0, 1, 0), 3)
	#draw_line(Vector2.ZERO, global_transform.basis_xform_inv(turn_left) * 50, Color(1, 0, 0), 2)
	#draw_line(Vector2.ZERO, global_transform.basis_xform_inv(turn_right) * 50, Color(1, 0, 0), 2)
	# #draw_line(Vector2.ZERO, accel_dir_debug * 50, Color(0, 0, 1), 2)
	# draw_line(Vector2.ZERO, global_transform.basis_xform_inv(dynamic_etr_left) * 50, Color(1,0,0), 4)
	# draw_line(Vector2.ZERO, global_transform.basis_xform_inv(dynamic_etr_right) * 50, Color(1,0,0), 4)
	# #draw_line(Vector2.ZERO, new_etr * 50, Color(0,0,1), 4)
	#draw_line(Vector2.ZERO, global_transform.basis_xform_inv(velocity) * 2, Color(1,1,1), 5) # white
	# #draw_line(Vector2.ZERO, global_transform.basis_xform_inv(accel_dir) * 50, Color(1,0,1), 4) # pink
	#draw_line(Vector2.ZERO, global_transform.basis_xform_inv(force_addition) * 50, Color(0,0,1), 3) #blue
	# #draw_line(Vector2.ZERO, global_transform.basis_xform_inv(maintained_vel) * 2, Color(1,1,0), 4) #yellow
	# #draw_line(Vector2.ZERO, global_transform.basis_xform_inv(transferred_vel) * 2, Color(0,1,1), 3) #teal
	# #draw_line(Vector2.ZERO, global_transform.basis_xform_inv(perp_vector) * 52, Color(0,0,1), 3) #blue
	#draw_line(Vector2.ZERO, global_transform.basis_xform_inv(medial_vel) * 2, Color(0.5,0.5,1), 3) #light blue
	#draw_line(Vector2.ZERO, global_transform.basis_xform_inv(lateral_vel) * 2, Color(1,0.5,0.5), 3) #pink
	#draw_line(Vector2.ZERO + Vector2.UP * 20, global_transform.basis_xform_inv(sign(rot_dir) * Vector2.RIGHT.rotated(rotation)) * 52, Color(0,0,1), 3) #blue
	pass

	# NOTES
	# The draw_line apparently does a rotation pass or something. So I have to pass an unrotated value or there will be a mismatch (double rotation)


################################## Function Declarations ########################################
#################################################################################################
func update_variables():
	gear = clamp(ceil((medial_vel.length() / MAX_SPEED) * 6), 1, 6)
	torque = POWER / gear
	fwd_dir = Vector2.UP.rotated(rotation)
	alignment = velocity.normalized().dot(fwd_dir) # 0 to 1

	is_braking = brake_check and alignment > 0
	brake_friction = 0.99 if is_braking else 1.0

#################################################################################################
func player_input():
	# Gather Inputs: Forward/Backward
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


	#############################################################################
	# Gather Inputs: Left/Right #################################################


	if Input.is_action_pressed(input_left):
		turn_left = Vector2.LEFT.rotated(rotation)
	else:
		turn_left = Vector2(0,0)
		
	if Input.is_action_pressed(input_right):
		turn_right = Vector2.RIGHT.rotated(rotation)
	else:
		turn_right = Vector2(0,0)

	var reverse_correct = sign(fwd_dir.dot(velocity))
	if reverse_correct == 0:
		reverse_correct = 1

	var steer_dir = (turn_left + turn_right).normalized() * reverse_correct
	if steer_dir == Vector2(0,0):							
		steer_dir = fwd_dir
	rot_dir = clamp(fwd_dir.cross(steer_dir), -1.0, 1.0)
	#############################################################################
	# Car Sprite Switcher #######################################################
	var steer_visual = steer_dir * reverse_correct
	if steer_visual == fwd_dir:
		$Sprite2D.frame = 0
	elif steer_visual == turn_left:
		$Sprite2D.frame = 1
	elif steer_visual == turn_right:
		$Sprite2D.frame = 2
	#############################################################################

#################################################################################################
func acceleration(delta):
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
	#############################################################################
	# Gather variable state #####################################################
	var vel_dir = velocity.normalized()
	var vel_mag = velocity.length()
	var medial_speed = velocity.dot(fwd_dir)
	medial_vel = medial_speed * fwd_dir
	lateral_vel = (velocity - medial_speed * fwd_dir)
	#############################################################################
	# Lateral Friction ##########################################################
	var lateral_mag = lateral_vel.length()
	var accel_factor = 0.997 # if not accelerating the friction value is reduced (friction increases)
	if is_accelerating:
		accel_factor = 1.0 # if accelerating the friction value stays at 100%
	var lateral_friction_ratio = lateral_mag / 100
	var lateral_friction_weight = clamp(lateral_friction_ratio, 0.0, 1.0)
	var lateral_friction = lerp(0.9, 0.99, lateral_friction_weight) * accel_factor
	#############################################################################
	# Medial Friction ###########################################################
		# This could probably be simplified
	var drag_coefficient = 0.02
	var rolling_friction = 0.9999 # WIP
	var drag_ratio = clamp(velocity.length_squared() / (MAX_SPEED * MAX_SPEED), 0.0, 0.1)
	var air_friction = 1.0 - drag_ratio * drag_coefficient
	var medial_friction = rolling_friction * air_friction * brake_friction
	#############################################################################
	# Velocities ################################################################
	lateral_vel *= lateral_friction
	medial_vel *= medial_friction
	velocity = (lateral_vel) + (medial_vel) + force_addition
	#############################################################################
	# Angular Friction ##########################################################
	var speed_ratio = clamp(velocity.length() / 200, 0.0, 1.0)
	var abs_alignment = abs(alignment) # 0 to 1
	if velocity == Vector2(0,0):
		abs_alignment = 1
		# More angular friction at low speed - May need to change but certainly works as a bandaid
	var angular_friction = lerp(0.1, 0.99, speed_ratio * (1.0 - abs_alignment))
	#############################################################################
	# Alignment Force ###########################################################
	var misalignment = vel_dir.cross(fwd_dir)
	traction = lerp(0.5, 1.0, abs_alignment)
	var aligning_force = traction * -misalignment
	#############################################################################
	# Rotation Momentum #########################################################
	var rot_speed = 4
	var rot_traction = traction * clamp(vel_mag/100, 0.0, 1.0)
		# Replace the 4 with a rot_speed or rot torque. Consider variability vs constant
		# May want rot_speed to be a value that increases with velocity? Or torque or sudden change in velocity?
		# rot_dir = User Input: -1, 0, or 1
	rot_momentum += (aligning_force + rot_speed * rot_traction * rot_dir) * delta
	rot_momentum *= pow(angular_friction, delta)
	rot_momentum = clamp(rot_momentum, -4, 4)
	#############################################################################
	# Rotation ##################################################################
	rotation += rot_momentum * delta

	#############################################################################





#################################################################################################
