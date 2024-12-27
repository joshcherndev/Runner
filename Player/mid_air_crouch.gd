extends State

@export var grounded_crouch_state: State
@export var fall_state: State

@export var max_crouch_speed = 5.0
@export var crouch_accel = 3.0
@onready var crouch_drag = crouch_accel / max_crouch_speed

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_released("crouch"):
		return fall_state
	
	return null

func process_physics(delta: float) -> State:
	if not parent.is_on_floor():
		parent.velocity.y -= gravity * delta
	
	parent.move_and_slide()
	
	if Input.is_action_pressed("crouch") and parent.is_on_floor():
		return grounded_crouch_state
	
	return null
