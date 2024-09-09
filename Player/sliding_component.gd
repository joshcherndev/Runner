class_name SlidingComponent
extends Node3D

@onready var sliding_ray_cast_3d = $SlidingRayCast3D

var is_crouching = false
@export var max_crouching_speed = 4.0
@export var crouching_accel = 2.0
@export var crouching_drag = float(crouching_accel) / max_crouching_speed

var is_sliding = false
@export var sliding_speed_sloped = 30.0
@export var sliding_speed_flat = 10.0
@export var sliding_buildup = 0.0
@export var sliding_buildup_amount = 0.05
@export var sliding_range = 4.0
@export var sliding_jump_force = 45.0
@export var sliding_speed_percentage = 0.0
@export var sliding_speed_percentage_buildup = 0.025
@export var sliding_flat_speed_percentage_buildup = 0.04
var prev_ground_normal = Vector3.ZERO
var prev_player_position = Vector3.ZERO
var sliding_uphill = false

@onready var player_mover = get_parent()
@onready var player: CharacterBody3D = player_mover.get_parent()

func _process(delta):
	# go to crouch from standing
	if Input.is_action_pressed("crouch"):
		# continue slide if sliding
		if is_sliding:
			handle_slide()
		# start slide if going fast enough
		elif !is_sliding and player.velocity.length() > 10.0 or player.velocity.y < -10.0:
			start_slide()
		elif !is_sliding:
			enable_crouching()
	
	# go from crouch to standing
	if Input.is_action_just_released("crouch"):
		disable_crouching()
		disable_sliding()

func start_slide():
	sliding_ray_cast_3d.enabled = true
	sliding_ray_cast_3d.force_raycast_update()
	
	if sliding_ray_cast_3d.is_colliding():
		var ground_normal = sliding_ray_cast_3d.get_collision_normal()
		
		# go into slide if the slope is not too steep
		if ground_normal.y >= 0.55:
			print("starting slide")
			is_sliding = true
			player.velocity += player_mover.move_dir_starting_slide
	
	sliding_ray_cast_3d.enabled = false

func handle_slide():
	sliding_ray_cast_3d.enabled = true
	sliding_ray_cast_3d.force_raycast_update()
	
	if sliding_ray_cast_3d.is_colliding():
		var ground_normal = sliding_ray_cast_3d.get_collision_normal()
		
		if sliding_speed_percentage == 0.0 or !prev_ground_normal.is_equal_approx(ground_normal):
			sliding_speed_percentage = 1 - ground_normal.y
		
		if ground_normal.y < 0.90:
			# check if player is sliding uphill
			if !sliding_uphill:
				var angle = rad_to_deg(acos(prev_ground_normal.dot(ground_normal) / (prev_ground_normal.length() * ground_normal.length())))
				angle = 180 - angle
				
				if prev_ground_normal.y > ground_normal.y and player.position.y > prev_player_position.y and angle < 180:
					sliding_uphill = true
			
			if sliding_speed_percentage > 1.0:
				sliding_speed_percentage = 1.0
			
			if sliding_uphill:
				player.velocity += Vector3(ground_normal.x, 0.0, ground_normal.z) * sliding_speed_percentage * 0.5
			else:
				player.velocity += Vector3(ground_normal.x, 0.0, ground_normal.z) * sliding_speed_percentage
			
			if player.velocity.length() < 10.0 and sliding_uphill:
				disable_sliding()
		else:
			#print(sliding_speed_percentage)
			if sliding_speed_percentage > 1.0 or (prev_ground_normal.y < ground_normal.y and sliding_uphill):
				disable_sliding()
				#print()
			else:
				player.velocity += player_mover.move_dir_starting_slide * 5.0 - player.velocity * sliding_speed_percentage
		
		sliding_speed_percentage += sliding_speed_percentage_buildup
		prev_player_position = player.position
		prev_ground_normal = ground_normal
	
	player.velocity += player_mover.move_dir * 0.01
	
	sliding_ray_cast_3d.enabled = false

func disable_sliding():
	is_sliding = false
	sliding_uphill = false
	reset_sliding_percentage()

func reset_sliding_percentage():
	sliding_speed_percentage = 0.0

func enable_crouching():
	is_crouching = true

func disable_crouching():
	is_crouching = false
