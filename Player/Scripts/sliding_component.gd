class_name SlidingComponent
extends Node3D

@export var speed_required_for_slide: float = 10.0
@export var max_sliding_speed = 16.0
@export var sliding_accel = 2.0
@onready var sliding_drag = sliding_accel / max_sliding_speed

@onready var sliding_ray_cast_3d = $SlidingRayCast3D

@onready var sliding = false
var move_dir_starting_slide: Vector3

@onready var player_mover = get_parent()
@onready var player: CharacterBody3D = player_mover.get_parent()

func _physics_process(delta):
	if not sliding and player.velocity.length() >= speed_required_for_slide and Input.is_action_pressed("crouch"):
		_start_slide()
	elif sliding:
		_handle_slide()
	
	if Input.is_action_just_released("crouch"):
		sliding = false

func _start_slide():
	sliding_ray_cast_3d.enabled = true
	sliding_ray_cast_3d.force_raycast_update()
	
	if sliding_ray_cast_3d.is_colliding():
		var ground_normal = sliding_ray_cast_3d.get_collision_normal()
		print(ground_normal)
		# go into slide if the slope is not too steep
		if ground_normal.y >= 0.55:
			sliding = true
			move_dir_starting_slide = player_mover.move_dir
	
	sliding_ray_cast_3d.enabled = false

func _handle_slide():
	sliding_ray_cast_3d.enabled = true
	sliding_ray_cast_3d.force_raycast_update()
	
	if sliding_ray_cast_3d.is_colliding():
		var ground_normal = sliding_ray_cast_3d.get_collision_normal()
		
		# For slopes
		if ground_normal.y <= 0.9:
			player_mover.comp_velocity += Vector3(ground_normal.x, 0, ground_normal.z)
		# For flat-ish ground
		elif ground_normal.y > 0.9:
			player_mover.comp_velocity += move_dir_starting_slide
	
	sliding_ray_cast_3d.enabled = false

func is_sliding():
	return sliding

#func _process(delta):
	#if !debug:
		## go to crouch from standing
		#if Input.is_action_pressed("crouch"):
			## continue slide if sliding
			#if is_sliding:
				#handle_slide()
			## start slide if going fast enough
			#elif !is_sliding and player.velocity.length() > 10.0 or player.velocity.y < -10.0:
				#start_slide()
			#elif !is_sliding:
				#enable_crouching()
		## go from crouch to standing
		#elif Input.is_action_just_released("crouch"):
			#disable_crouching()
			#disable_sliding()
#
#func handle_slide():
	#sliding_ray_cast_3d.enabled = true
	#sliding_ray_cast_3d.force_raycast_update()
	#
	#if sliding_ray_cast_3d.is_colliding():
		#var ground_normal = sliding_ray_cast_3d.get_collision_normal()
		#
		#if sliding_speed_percentage == 0.0 or !prev_ground_normal.is_equal_approx(ground_normal):
			#sliding_speed_percentage = 1 - ground_normal.y
		#
		#if ground_normal.y < 0.90:
			## check if player is sliding uphill
			#if !sliding_uphill:
				#var angle = rad_to_deg(acos(prev_ground_normal.dot(ground_normal) / (prev_ground_normal.length() * ground_normal.length())))
				#angle = 180 - angle
				#
				#if prev_ground_normal.y > ground_normal.y and player.position.y > prev_player_position.y and angle < 180:
					#sliding_uphill = true
			#
			#if sliding_speed_percentage > 1.0:
				#sliding_speed_percentage = 1.0
			#
			#if sliding_uphill:
				#player.velocity += Vector3(ground_normal.x, 0.0, ground_normal.z) * sliding_speed_percentage * 0.5
			#else:
				#player.velocity += Vector3(ground_normal.x, 0.0, ground_normal.z) * sliding_speed_percentage
			#
			#if player.velocity.length() < 10.0 and sliding_uphill:
				#disable_sliding()
		#else:
			#if sliding_speed_percentage > 1.0 or (prev_ground_normal.y < ground_normal.y and sliding_uphill):
				#disable_sliding()
			#else:
				#player.velocity += player_mover.move_dir_starting_slide * 5.0 - player.velocity * sliding_speed_percentage
		#
		#sliding_speed_percentage += sliding_speed_percentage_buildup
		#prev_player_position = player.position
		#prev_ground_normal = ground_normal
	#
	#player.velocity += player_mover.move_dir * 0.01
	#
	#sliding_ray_cast_3d.enabled = false
#
#func disable_sliding():
	#is_sliding = false
	#sliding_uphill = false
	#reset_sliding_percentage()
#
#func reset_sliding_percentage():
	#sliding_speed_percentage = 0.0
#
#func enable_crouching():
	#is_crouching = true
#
#func disable_crouching():
	#is_crouching = false
