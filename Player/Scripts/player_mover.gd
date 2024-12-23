class_name PlayerMover
extends Node3D

@onready var sliding_component = $SlidingComponent
@onready var crouch_component = $CrouchComponent
@onready var climbing_component = $ClimbingComponent
@onready var sprinting_component = $SprintingComponent
@onready var jump_component = $JumpComponent
@onready var stairs_component = $StairsComponent

@export var max_walk_speed = 10.0
@export var walk_accel = 2.0
@export var stop_drag = 0.4
@onready var walk_drag = walk_accel / max_walk_speed
@export var gravity = 40.0

@onready var player: CharacterBody3D = get_parent()
@onready var input_dir: Vector2 = Vector2.ZERO
@onready var move_dir: Vector3 = Vector3.ZERO
var last_non_zero_move_dir: Vector3
var snapped_to_floor = false

@onready var comp_velocity: Vector3 = Vector3.ZERO

var debug = false

func _physics_process(delta):
	if debug:
		# Update gravity for when player is not on a floor
		if !player.is_on_floor():
			player.velocity.y -= gravity * delta
		if player.velocity.y > 0.0 and player.is_on_ceiling():
			player.velocity.y = 0.0
		
		_set_move_dir()
		
		# Add jump and slide velocities to the player velocity before updating
		player.velocity += comp_velocity
		
		# NOT SLIDING
		if not sliding_component.is_sliding():
			var drag = _get_drag()
			var accel = _get_accel()
			
			
		else:
			player.velocity = player.velocity.clamp(Vector3(-9999, -9999, -9999), Vector3(sliding_component.max_sliding_speed, 99999, sliding_component.max_sliding_speed))
		
		
		if not stairs_component.snap_up_stairs_check(delta):
			# snap_up_stairs_check moves the player manually, so don't call move_and_slide.
			# should be fine as we ensure with body_test_motion that the player doesn't collide
			# with anything except the stair its moving up to.
			player.move_and_slide() 
			stairs_component.snap_down_to_stairs_check()
		
		snapped_to_floor = stairs_component.snapped_to_stairs_last_frame
		comp_velocity = Vector3.ZERO

func _set_move_dir():
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward").normalized()
	move_dir = (player.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y))
	if move_dir.length() > 0.0:
		last_non_zero_move_dir = move_dir

func _get_drag():
	var drag = walk_drag
	if sprinting_component.is_sprinting():
		drag = sprinting_component.sprinting_drag
	elif crouch_component.is_crouching() and not sprinting_component.is_sprinting():
		drag = crouch_component.crouching_drag
	elif move_dir.is_zero_approx():
		drag = stop_drag
	return drag

func _get_accel():
	var accel = walk_accel
	if sprinting_component.is_sprinting():
		accel = sprinting_component.sprinting_accel
	if crouch_component.is_crouching() and not sprinting_component.is_sprinting():
		accel = crouch_component.crouching_accel
	return accel

func is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > player.floor_max_angle

func _disable_jump():
	jump_component.disabled = true

func _enable_jump():
	jump_component.disabled = false

func get_input_dir():
	return input_dir
