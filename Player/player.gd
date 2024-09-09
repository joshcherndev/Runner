extends CharacterBody3D

@onready var player_mover = $PlayerMover
@onready var player_camera: Camera3D = $PlayerCamera

@onready var standing_collision_shape_3d = $StandingCollisionShape3D
@onready var crouching_collision_shape_3d = $CrouchingCollisionShape3D

@onready var state_animation_player = $StateAnimationPlayer

@export var mouse_sensitivity_h = 0.15
@export var mouse_sensitivity_v = 0.15

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		var fs = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		if fs:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	player_mover.set_move_dir(move_dir)
	
	# go to crouch from standing
	if Input.is_action_pressed("crouch"):
		state_animation_player.play("crouch")
	if Input.is_action_just_pressed("crouch"):
		crouching_collision_shape_3d.disabled = false
		standing_collision_shape_3d.disabled = true
	
	# go from crouch to standing
	if Input.is_action_just_released("crouch"):
		crouching_collision_shape_3d.disabled = true
		standing_collision_shape_3d.disabled = false
		state_animation_player.play("RESET")
	
	player_camera.tilt_camera(input_dir, player_mover.check_is_sprinting(), player_mover.check_is_sliding(), delta)

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity_h
		player_camera.rotation_degrees.x -= event.relative.y * mouse_sensitivity_v
		player_camera.rotation_degrees.x = clamp(player_camera.rotation_degrees.x, -90, 90)
