extends Node

# Return the desired direction of movement for the player via a
# Vector2 that contains a horizontal direction vector.
func get_movement_direction() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward").normalized()

# Return a boolean indicating if the player wants to jump
func wants_jump() -> bool:
	return Input.is_action_just_pressed('jump')
