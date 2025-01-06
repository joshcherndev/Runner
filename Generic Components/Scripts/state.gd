class_name State
extends Node3D

## Base State class that acts as an interface for new states to be built from

@export var animation_name: String

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir_entering_state: Vector3

var animations: AnimationPlayer
var move_component
var parent: CharacterBody3D

# Called when the state is entered to intialize fields and behavior
func enter() -> void:
	animations.play(animation_name)
	var input_dir = get_movement_input()
	move_dir_entering_state = parent.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)

# Called when the state is exited and wrap up behavior is activated
func exit() -> void:
	pass

# Process player inputs that return a new state for the state machine to enter
func process_input(event: InputEvent) -> State:
	return null

# Process frame data and return new state for state machine to enter
func process_frame(delta: float) -> State:
	return null

# Process physics frame data and return new state for the state machine to enter
func process_physics(delta: float) -> State:
	return null

# Get player movement input infortmation as a normalized Vector2 from a move_component
func get_movement_input() -> Vector2:
	return move_component.get_movement_direction()

# Get jump valid jump inputs as a boolean that tells the character they can 
# jump based on logic in move_component
func get_jump() -> bool:
	return move_component.wants_jump()

# Special case of valid jump input handling for coyote time jumps handled in move_component
func get_jump_during_fall() -> bool:
	return move_component.wants_jump_during_fall()

# Get valid climb inputs as a boolean that tells the character they can
# climb based on logic in the move_component
func get_climb() -> bool:
	return move_component.wants_climb()

# Get valid slide inputs as a boolean that tells the character they can
# slide based on logic in the move_component
func get_slide() -> bool:
	return move_component.wants_slide()
