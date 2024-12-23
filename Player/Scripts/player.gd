extends CharacterBody3D

@onready var player_mover = $PlayerMover
@onready var player_camera: Camera3D = $PlayerCamera

@onready var standing_collision_shape_3d = $StandingCollisionShape3D
@onready var crouching_collision_shape_3d = $CrouchingCollisionShape3D

@onready var movement_state_machine = $MovementStateMachine
@onready var animations = $Animations
@onready var player_move_component = $PlayerMoveComponent

@export var mouse_sensitivity_h = 0.15
@export var mouse_sensitivity_v = 0.15

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	movement_state_machine.init(self, animations, player_move_component)

func _unhandled_input(event: InputEvent) -> void:
	movement_state_machine.process_input(event)
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity_h
		player_camera.rotation_degrees.x -= event.relative.y * mouse_sensitivity_v
		player_camera.rotation_degrees.x = clamp(player_camera.rotation_degrees.x, -90, 90)

func _physics_process(delta: float) -> void:
	movement_state_machine.process_physics(delta)

func _process(delta):
	# Enter full screen on 'f'
	if Input.is_action_just_pressed("fullscreen"):
		var fs = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		if fs:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	# Quit game on 'esc'
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	
	movement_state_machine.process_frame(delta)
	
	# TODO: move into a state in the state machine
	# Control mesh and collision shapes when crouched and standing
	# STANDING -> CROUCH
	if Input.is_action_pressed("crouch"):
		animations.play("crouch")
	if Input.is_action_just_pressed("crouch"):
		crouching_collision_shape_3d.disabled = false
		standing_collision_shape_3d.disabled = true
	# CROUCH -> STANDING
	if Input.is_action_just_released("crouch"):
		crouching_collision_shape_3d.disabled = true
		standing_collision_shape_3d.disabled = false
		animations.play("RESET")
	
	
	
	
	# Logic for camera movement called here
	player_camera.tilt_camera(player_mover.get_input_dir(), delta)
