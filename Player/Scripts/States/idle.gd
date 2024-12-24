extends State

@export var walk_state: State
@export var sprint_state: State
@export var crouch_state: State
@export var jump_state: State
@export var fall_state: State

@export var idle_drag: float = 0.4

func process_input(event: InputEvent) -> State:
	if get_movement_input() != Vector2.ZERO:
		return walk_state
	if Input.is_action_pressed("sprint") and Input.is_action_pressed("move_forward") and parent.is_on_floor:
		return sprint_state
	if Input.is_action_pressed("crouch"):
		return crouch_state
	if get_jump() and parent.is_on_floor():
		return jump_state
	return null

func process_physics(delta: float) -> State:
	if not parent.is_on_floor():
		parent.velocity.y -= gravity * delta
	
	# Slow the parent down until they stop moving if their
	# velocity vector is not Vector2.ZERO yet.
	if not is_equal_approx(parent.velocity.length(), 0.0):
		var flat_velo = parent.velocity
		flat_velo.y = 0.0
		parent.velocity -= flat_velo * idle_drag
		parent.move_and_slide()
	
	# Parent no longer has floor underneath, begin falling
	if !parent.is_on_floor():
		return fall_state
	return null
