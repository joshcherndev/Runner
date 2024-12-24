extends State

@export var idle_state: State
@export var walk_state: State
@export var sprint_state: State
@export var crouch_state: State
@export var fall_state: State

@export var jump_force: float = 12.0
@export var jump_drag: float = 0.05

func enter() -> void:
	super()
	parent.velocity.y += jump_force

func process_physics(delta: float) -> State:
	if not parent.is_on_floor():
		parent.velocity.y -= gravity * delta
	
	if parent.velocity.y < 0:
		return fall_state
	if parent.is_on_ceiling():
		parent.velocity.y = 0
		return fall_state
	
	var input_dir = get_movement_input()
	# Align movement direction to be on the current transform's basis
	var move_dir = parent.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	var flat_velo = parent.velocity
	flat_velo.y = 0.0
	
	if Input.is_action_pressed('sprint') and move_dir.length() != 0.0:
		parent.velocity += sprint_state.sprint_accel * move_dir - flat_velo * sprint_state.sprint_drag
	if Input.is_action_pressed('crouch') and move_dir.length() != 0.0:
		parent.velocity += crouch_state.crouch_accel * move_dir - flat_velo * crouch_state.crouch_drag
	elif move_dir.length() != 0.0:
		parent.velocity += walk_state.walk_accel * move_dir - flat_velo * walk_state.walk_drag
	# If no movement input detected, slow down velocity to a stop
	else:
		parent.velocity -= flat_velo * jump_drag
	
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if input_dir.length() != 0 and Input.is_action_pressed('sprint'):
			return sprint_state
		if input_dir.length() != 0:
			return walk_state
		return idle_state
	
	return null