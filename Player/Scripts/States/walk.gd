extends State

@export var idle_state: State
@export var sprint_state: State
@export var crouch_state: State
@export var jump_state: State
@export var fall_state: State
@export var climb_state: State

@export var max_walk_speed = 10.0
@export var walk_accel = 1.0
@onready var walk_drag = walk_accel / max_walk_speed

func process_input(event: InputEvent) -> State:
	if Input.is_action_pressed("crouch") and parent.is_on_floor():
		return crouch_state
	if Input.is_action_pressed('sprint') and Input.is_action_pressed("move_forward") and not Input.is_action_pressed("crouch") and parent.is_on_floor():
		return sprint_state
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
	parent.velocity += walk_accel * move_dir - flat_velo * walk_drag
	
	# Parent no longer has floor underneath, begin falling
	if !parent.is_on_floor():
		return fall_state
	return null
