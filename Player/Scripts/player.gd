class_name Player
extends CharacterBody3D

## Contains logic for rotating character, state machine initialization,
## camera update logic, input handling for window management, and updating debug UI.

@onready var player_camera: Camera3D = $PlayerCamera

# References for state machine initialization
@onready var movement_state_machine = $MovementStateMachine
@onready var animations = $Animations
@onready var player_move_component = $PlayerMoveComponent

@export var mouse_sensitivity_h = 0.15
@export var mouse_sensitivity_v = 0.15

# References for basic UI displaying state information
@onready var state_label = $VBoxContainer/StateLabel
@onready var prev_state_label = $VBoxContainer/PrevStateLabel
@onready var anim_label = $VBoxContainer/AnimLabel
@onready var velocity_label = $VBoxContainer/VelocityLabel

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# State machine initialization
	movement_state_machine.init(self, animations, player_move_component)
	
	# State debug UI initialization
	movement_state_machine.state_changed.connect(_update_state_text)
	animations.current_animation_changed.connect(_update_anim_text)
	anim_label.text = "Anim: " + animations.current_animation

func _unhandled_input(event: InputEvent) -> void:
	movement_state_machine.process_input(event) # movement state machine input update
	
	# Character rotation logic
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity_h
		player_camera.rotation_degrees.x -= event.relative.y * mouse_sensitivity_v
		player_camera.rotation_degrees.x = clamp(player_camera.rotation_degrees.x, -90, 90)

func _physics_process(delta: float) -> void:
	movement_state_machine.process_physics(delta) # movement state machine physics frame update
	
	# This is where move_and_slide() is called for the player
	player_move_component.process_movement_with_correction(delta)

func _process(delta):
	movement_state_machine.process_frame(delta) # movement state machine physics frame update
	
	# Enter full screen on 'f', go back to window on 'f'
	if Input.is_action_just_pressed("fullscreen"):
		var fs = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		if fs:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	# Change mouse mode on 'esc'
	if Input.is_action_just_pressed("exit"):
		var mm = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
		if mm:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Logic for up and down camera movement called here
	player_camera.tilt_camera(player_move_component.get_movement_direction(), delta)
	
	_update_velocity_text() # Debug UI update

# Basic State debug UI update function
func _update_state_text() -> void:
	state_label.text = 'State: ' + movement_state_machine.current_state.name
	prev_state_label.text = 'Prev State: ' + movement_state_machine.prev_state.name

# Basic State debug UI update function
func _update_anim_text(anim: String):
	anim_label.text = "Anim: " + anim

# Basic State debug UI update function
func _update_velocity_text() -> void:
	velocity_label.text = 'm/s (x/z, y): ' + '(' + str(_hundredth(Vector2(self.velocity.x, self.velocity.z).length())) + ', ' + str(_hundredth(self.velocity.y)) + ')'

# Helper function for rounding floats for labels
func _hundredth(num: float) -> float:
	return (int(num * 100.0)) / 100.0
