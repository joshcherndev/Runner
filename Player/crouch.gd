extends State

@export var idle_state: State
@export var walk_state: State
@export var sprint_state: State
@export var jump_state: State
@export var fall_state: State

@export var max_crouch_speed = 5.0
@export var crouch_accel = 3.0
@onready var crouch_drag = crouch_accel / max_crouch_speed

func process_input(event: InputEvent) -> State:
	if Input.is_action_pressed('sprint') and Input.is_action_pressed('move_forward') and parent.is_on_floor:
		return sprint_state
	if get_jump() and parent.is_on_floor():
		return jump_state
	
	return null

func process_physics(delta: float) -> State:
	if not parent.is_on_floor():
		parent.velocity.y -= gravity * delta
	
	var input_dir = get_movement_input()
	# Align movement direction to be on the current transform's basis
	var move_dir = parent.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	
	if Input.is_action_just_released('crouch') and move_dir.length() != 0.0:
		return walk_state
	# No input detected, begin idling
	if Input.is_action_just_released('crouch') and move_dir.length() == 0.0:
		return idle_state
	
	var flat_velo = parent.velocity
	flat_velo.y = 0.0
	parent.velocity += crouch_accel * move_dir - flat_velo * crouch_drag
	
	parent.move_and_slide()
	
	# Parent no longer has floor underneath, begin falling
	if !parent.is_on_floor():
		return fall_state
	return null