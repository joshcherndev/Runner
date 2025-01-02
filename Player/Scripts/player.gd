class_name Player
extends CharacterBody3D

@onready var player_camera: Camera3D = $PlayerCamera

@onready var standing_collision_shape_3d = $StandingCollisionShape3D
@onready var crouching_collision_shape_3d = $CrouchingCollisionShape3D

@onready var movement_state_machine = $MovementStateMachine
@onready var animations = $Animations
@onready var player_move_component = $PlayerMoveComponent

@export var mouse_sensitivity_h = 0.15
@export var mouse_sensitivity_v = 0.15

@onready var state_label = $VBoxContainer/StateLabel
@onready var prev_state_label = $VBoxContainer/PrevStateLabel
@onready var anim_label = $VBoxContainer/AnimLabel
@onready var velocity_label = $VBoxContainer/VelocityLabel

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	movement_state_machine.init(self, animations, player_move_component)
	movement_state_machine.state_changed.connect(_update_state_text)
	animations.current_animation_changed.connect(_update_amim_text)
	anim_label.text = "Anim: " + animations.current_animation

func _unhandled_input(event: InputEvent) -> void:
	movement_state_machine.process_input(event)
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity_h
		player_camera.rotation_degrees.x -= event.relative.y * mouse_sensitivity_v
		player_camera.rotation_degrees.x = clamp(player_camera.rotation_degrees.x, -90, 90)

func _physics_process(delta: float) -> void:
	movement_state_machine.process_physics(delta)
	# This is where move_and_slide() is called
	player_move_component.process_movement_with_correction(delta)

func _process(delta):
	# Enter full screen on 'f', go back to window on 'f'
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
	
	# Logic for camera movement called here
	player_camera.tilt_camera(player_move_component.get_movement_direction(), delta)
	
	_update_velocity_text()

func _update_state_text() -> void:
	state_label.text = 'State: ' + movement_state_machine.current_state.name
	prev_state_label.text = 'Prev State: ' + movement_state_machine.prev_state.name

func _update_amim_text(anim: String):
	anim_label.text = "Anim: " + anim

func _update_velocity_text() -> void:
	velocity_label.text = 'm/s (x/z, y): ' + '(' + str(_hundredth(Vector2(self.velocity.x, self.velocity.z).length())) + ', ' + str(_hundredth(self.velocity.y)) + ')'

func _hundredth(num: float) -> float:
	return (int(num * 100.0)) / 100.0
