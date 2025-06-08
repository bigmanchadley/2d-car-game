extends CharacterBody2D


@export var input_up: String
@export var input_down: String
@export var input_left: String
@export var input_right: String

##### Constants #####
const MAX_SPEED = 300
const POWER = 300
const TRACTION = 30


@export var rot_const = 4

#### Sound ####
var rpm: float
var throttle := 0.0
var prev_gear



##### Variables #####
var fwd_dir: Vector2
var accel_dir: Vector2
var alignment: float
var gear
var torque
var brake_check: bool
var is_braking: bool
var brake_friction: float
var rot_dir: float
var is_turning_left: bool
var is_turning_right: bool
var reverse_check: bool
var is_reversing: bool

# _ready
var force_addition: Vector2
var is_accelerating: bool 
var grip: float
var rot_momentum: float
var medial_vel: Vector2
var lateral_vel: Vector2
var t_l: float
var t_r: float


###################################### START MAIN ############################################
func _physics_process(delta):
	update_variables()
	player_input(delta)
	acceleration(delta)
	steering(delta)
	
	queue_redraw()
	move_and_slide()


func _ready():
	velocity = Vector2.ZERO
	force_addition = Vector2.ZERO
	is_accelerating = false
	is_reversing = false
	grip = 1.0
	rot_momentum = 0.0
	medial_vel = Vector2(0,0)
	lateral_vel = Vector2(0,0)
	prev_gear = gear
	t_l = 0.0
	t_r = 0.0
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


################################## Function Declarations ########################################
#################################################################################################
func update_variables():
	gear = clamp(ceil((medial_vel.length() / MAX_SPEED) * 6), 1, 6)
	torque = POWER / gear
	# rpms

	fwd_dir = Vector2.UP.rotated(global_rotation)
	alignment = velocity.normalized().dot(fwd_dir) # 0 to 1
	is_braking = brake_check and alignment > 0.1
	brake_friction = 0.99 if is_braking else 1.0
	is_reversing = alignment < 0.0 and is_braking == false

func get_rpm():
	return rpm

#################################################################################################
func player_input(delta):
	var fwd_input: Vector2
	var bwd_input: Vector2
	var turn_left: Vector2
	var turn_right: Vector2


	# Gather Inputs: Forward/Backward
	if Input.is_action_pressed(input_up):
		fwd_input = Vector2(0, -1)
		is_reversing = false
		throttle = lerp(throttle, 1.0, delta * 3.0)
	else:
		fwd_input = Vector2(0,0)
		throttle = lerp(throttle, 0.0, delta * 3.0)


	if Input.is_action_pressed(input_down):
		bwd_input = Vector2(0, 1)
		brake_check = true
		reverse_check = true
	else:
		bwd_input = Vector2(0,0)
		brake_check = false
		reverse_check = false
	# Store Acceleration direction
	accel_dir = (fwd_input + bwd_input).rotated(global_rotation).normalized()


	#############################################################################
	# Gather Inputs: Left/Right #################################################


	if Input.is_action_pressed(input_left):
		t_l = min(t_l + delta, 1.0)
		turn_left = Vector2.LEFT.rotated(global_rotation) * t_l
		is_turning_left = true
	else:
		t_l = 0.0
		turn_left = Vector2(0,0)
		is_turning_left = false
	if Input.is_action_pressed(input_right):
		t_r = min(t_r + delta, 1.0)
		turn_right = Vector2.RIGHT.rotated(global_rotation) * t_r
		is_turning_right = true
	else:
		t_r = 0.0
		turn_right = Vector2(0,0)
		is_turning_right = false

	var steer_dir = (turn_left + turn_right).normalized()
	rot_dir = clamp(fwd_dir.cross(steer_dir), -1.0, 1.0)
	if is_reversing == true:
		rot_dir *= -1.0


	#############################################################################
	# Car Sprite Switcher #######################################################
	var turn_direction = 0
	turn_direction = int(is_turning_left) + int(is_turning_right)
	if turn_direction == 0 or turn_direction == 2:
		$Sprite2D.frame = 0
	elif is_turning_left:
		$Sprite2D.frame = 1
	elif is_turning_right:
		$Sprite2D.frame = 2
	#############################################################################

#################################################################################################
func acceleration(delta):
	force_addition = (accel_dir * torque * grip * delta) * brake_friction
	if force_addition != Vector2(0,0):
		is_accelerating = true
	else:
		is_accelerating = false
	if is_braking:
		is_accelerating = false
		force_addition *= 0.2

	#rpms
	var speed_rpm = medial_vel.length()
	var input_rpm = throttle * 7000.0
	var target_rpm = clamp(max(speed_rpm, input_rpm), 800.0, 7000.0)
	rpm = lerp(rpm, target_rpm, delta * 1.0)

	

	if rpm > 6500.0 and gear != prev_gear:
		rpm = 1000.0 * gear
	prev_gear = gear


#################################################################################################
func steering(delta):
	#############################################################################
	# Gather variable state #####################################################
	var vel_dir = velocity.normalized()
	var vel_mag = velocity.length()
	var medial_speed = velocity.dot(fwd_dir)
	medial_vel = medial_speed * fwd_dir
	lateral_vel = (velocity - medial_speed * fwd_dir)
	var medial_mag = medial_vel.length()
	var misalignment = vel_dir.cross(fwd_dir)

	#############################################################################
	# Lateral Friction ##########################################################
	var lateral_mag = lateral_vel.length()
	var accel_factor = 0.997 # if not accelerating the friction value is reduced (friction increases)
	if is_accelerating:
		#accel_factor = 1.0 # if accelerating the friction value stays at 100%
		var torque_ratio = clamp(vel_mag/300, 0.0, 1.0) * abs(misalignment)
		accel_factor = lerp(1.0, 1.005, torque_ratio)
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
	var new_velocity
	
	new_velocity = (lateral_vel) + (medial_vel) + force_addition
	#############################################################################
	# Angular Friction ##########################################################
	var speed_ratio = clamp(velocity.length() / 100, 0.0, 1.0)
	var abs_alignment = abs(alignment) # 0 to 1
	if velocity == Vector2(0,0):
		abs_alignment = 1
		# More angular friction at low speed - May need to change but certainly works as a bandaid
	var rot_momentum_weight = clamp(abs(rot_momentum) / 2.0, 0.0, 1.0)
	var angular_friction = lerp(0.1, 0.99, speed_ratio * rot_momentum_weight)
	#############################################################################
	# Alignment Force ###########################################################
	grip = lerp(0.5, 1.0, abs_alignment)
	var aligning_force = grip * -misalignment
	#print_debug("align_force:	", aligning_force)
	#############################################################################
	# Rotation Momentum #########################################################
	var rot_traction = grip * clamp(vel_mag/200, 0.0, 1.0)
	var torque_factor = clamp(torque / 100, 0.0, 1.0)
	var velocity_factor = clamp(vel_mag / MAX_SPEED, 0.0, 1.0)
	var rot_torque = lerp(0.0, 3.0, velocity_factor  * torque_factor * abs_alignment * int(is_accelerating))
	var rot_input = (rot_const + rot_torque) * rot_traction * rot_dir

	rot_momentum += (aligning_force + rot_input) * delta
	rot_momentum *= pow(angular_friction, delta)
	rot_momentum = clamp(rot_momentum, -6, 6)
	
	var new_rotation = rot_momentum * delta
	
	#############################################################################
	# Rotation ##################################################################
	velocity = new_velocity
	rotation += new_rotation #* (medial_mag / 150)

	#############################################################################
#################################################################################



# Issue: Car always gathering and applying rotational momentum to rotation
# Possible Fixes:
	# 1: Rotational momentum does not apply until it is above a certain value
		# Doesn't work, because you are still gathering rotational momentum and will suddenly spin like a top when value is reached
	# 2: Car does not generate rotational momentum until a separate value is reached
		# Might affec

# Case Study:
	# Car is driving fast. Car swerves left, begins drifting with rotational momentum.
		# Car then swerves right, to the same degree it did to the left
		# At some point the car was aligned in the direction of velocity. However, that doesn't make it snap to no momentum and drive "normally"
		# So the rotational momentum is preserved as long as multiple factors are met
		# Factors:
			# Traction
			# Change in rotation
			# Velocity
			# Cornering Force

			# Assume turning left and right is variable determined by length of keypress to a maximum
			# The degree of steering gives the turning radius, up to a maximum
			# Flow:
				# Car has no velocity, car wheels turn left or right, nothing happens
				# Car has a velocity, car wheels turn left or right, something happens
					# The turning radius * velocity = rotation
					# The change in rotation



			# Traction: Constant -> Overcome by Centrifugal Force (and/or Rotational Momentum?)
			# Centrifugal: Variable -> Generated by Velocity relative to Steer Degree?
			# Rotational M: Variable -> Generated by Change-in-Rotation relative to Change-in-Velocity?
			

		# Traction (constant)(vector)
			# overcome by Rotational momentum?



		# input rotdir range -1 to 1




		# new rotation = rotational momentum and  
