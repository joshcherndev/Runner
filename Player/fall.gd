extends State

@export var idle_state: State
@export var walk_state: State
@export var sprint_state: State

@export var fall_drag: float = 0.05

func process_physics(delta: float) -> State:
	if not parent.is_on_floor():
		parent.velocity.y -= gravity * delta
	
	var input_dir = get_movement_input()
	# Align movement direction to be on the current transform's basis
	var move_dir = parent.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	var flat_velo = parent.velocity
	flat_velo.y = 0.0
	
	if Input.is_action_pressed('sprint') and move_dir.length() != 0.0:
		parent.velocity += sprint_state.sprint_accel * move_dir - flat_velo * sprint_state.sprint_drag
	elif move_dir.length() != 0.0:
		parent.velocity += walk_state.walk_accel * move_dir - flat_velo * walk_state.walk_drag
	# If no movement input detected, slow down velocity to a stop
	else:
		parent.velocity -= flat_velo * fall_drag
	
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if input_dir.length() != 0 and Input.is_action_pressed('sprint'):
			return sprint_state
		if input_dir.length() != 0:
			return walk_state
		return idle_state
	
	return null
