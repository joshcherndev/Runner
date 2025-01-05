extends State

@export var idle_state: State
@export var walk_state: State
@export var sprint_state: State
@export var jump_state: State
@export var grounded_crouch_state: State
@export var mid_air_crouch_state: State
@export var climb_state: State

@export var fall_drag: float = 0.05

# Used to check which horizontal speed to maintain when falling
var sprinting

func enter() -> void:
	super()
	if jump_state.sprinting:
		sprinting = true
	else:
		sprinting = false

func process_input(event: InputEvent) -> State:
	if get_climb():
		return climb_state
	if Input.is_action_pressed("crouch"):
		return mid_air_crouch_state
	if get_jump_during_fall():
		return jump_state
	
	return null

func process_physics(delta: float) -> State:
	if not parent.is_on_floor():
		parent.velocity.y -= gravity * delta
	
	var input_dir = get_movement_input()
	# Align movement direction to be on the current transform's basis
	var move_dir = parent.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	var flat_velo = parent.velocity
	flat_velo.y = 0.0
	
	# If player jumps while sprinting and continues to hold sprint, maintain velocity speed.
	# When they let go of sprint, disable the ability to go into sprint velocity again.
	if sprinting:
		if Input.is_action_pressed('sprint') and move_dir.length() != 0.0:
			parent.velocity += sprint_state.sprint_accel * move_dir - flat_velo * sprint_state.sprint_drag
		else:
			sprinting = false
	else:
		# If player is not sprinting but still is inputing a direction, use horizontal walk velocity.
		if move_dir.length() != 0.0:
			parent.velocity += walk_state.walk_accel * move_dir - flat_velo * walk_state.walk_drag
		# If no movement input detected, slow down velocity to a stop.
		else:
			parent.velocity -= flat_velo * fall_drag
	
	if parent.is_on_floor():
		if Input.is_action_pressed("move_forward") and Input.is_action_pressed('sprint'):
			return sprint_state
		if input_dir.length() != 0:
			return walk_state
		return idle_state
	
	return null
