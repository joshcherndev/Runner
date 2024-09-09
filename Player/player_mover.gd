class_name PlayerMover
extends Node3D

@onready var sliding_component = $SlidingComponent
@onready var climbing_component = $ClimbingComponent
@onready var sprinting_component = $SprintingComponent
@onready var jump_component = $JumpComponent

@export var max_walk_speed = 10.0
@export var walk_accel = 2.0
@export var stop_drag = 0.4
@onready var walk_drag = float(walk_accel) / max_walk_speed
@export var gravity = 40.0

@onready var player: CharacterBody3D = get_parent()
var move_dir: Vector3
var last_non_zero_move_dir: Vector3
var velocity_before_sliding: Vector3
var move_dir_starting_slide: Vector3

func _physics_process(delta):
	if !sliding_component.is_sliding:
		var accel = walk_accel
		var drag = walk_drag
		if sliding_component.is_crouching and !sliding_component.is_sliding and player.is_on_floor():
			accel = sliding_component.crouching_accel
		elif sprinting_component.is_sprinting:
			accel = sprinting_component.sprinting_accel
		
		if sliding_component.is_crouching and !sliding_component.is_sliding and player.is_on_floor():
			drag = sliding_component.crouching_drag
		elif sprinting_component.is_sprinting:
			drag = sprinting_component.sprinting_drag
		
		if move_dir.is_zero_approx():
			drag = stop_drag
		
		var flat_velo = player.velocity
		flat_velo.y = 0.0
		player.velocity += walk_accel * move_dir - flat_velo * drag
		velocity_before_sliding = player.velocity
		move_dir_starting_slide = move_dir
	
	if !player.is_on_floor():
		player.velocity.y -= gravity * delta
		velocity_before_sliding.y -= gravity * delta
	
	player.move_and_slide()

func set_move_dir(new_move_dir: Vector3):
	move_dir = new_move_dir
	move_dir.y = 0.0
	move_dir = move_dir.normalized()
	if move_dir.length() > 0.0:
		last_non_zero_move_dir = move_dir

func check_is_sprinting() -> bool:
	return sprinting_component.is_sprinting

func check_is_sliding() -> bool:
	return sliding_component.is_sliding

func check_is_crouching() -> bool:
	return sliding_component.is_crouching

func disable_jump():
	jump_component.disabled = true

func enable_jump():
	jump_component.disabled = false
