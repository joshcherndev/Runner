extends State

@export var idle_state: State
@export var walk_state: State
@export var crouch_state: State
@export var jump_state: State
@export var fall_state: State
@export var climb_state: State

@export var max_sprint_speed = 14.0
@export var sprint_accel = 3.0
@onready var sprint_drag = sprint_accel / max_sprint_speed

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_pressed('crouch'):
		return crouch_state
	var input_dir = get_movement_input()
	if Input.is_action_just_released('sprint') and input_dir.length() != 0.0:
		return walk_state
	if Input.is_action_just_released('sprint'):
		return idle_state
	if get_jump() and parent.is_on_floor():
		return jump_state
	if get_climb():
		return climb_state
	
	return null

func process_physics(delta: float) -> State:
	if not parent.is_on_floor():
		parent.velocity.y -= gravity * delta
	
	var input_dir = get_movement_input()
	# Align movement direction to be on the current transform's basis
	var move_dir = parent.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	
	# No input detected, begin idling
	if move_dir.length() == 0:
		return idle_state
	
	var flat_velo = parent.velocity
	flat_velo.y = 0.0
	parent.velocity += sprint_accel * move_dir - flat_velo * sprint_drag
	
	# Parent no longer has floor underneath, begin falling
	if !parent.is_on_floor():
		return fall_state
	return null
