extends Node3D

@export var speed_required_for_slide: float = 16.0
@export var steepness_for_slide: float = 0.925

@onready var player = get_parent()
@onready var ledge_detection_ray_cast_3d = $ClimbNodes/LedgeDetectionRayCast3D
@onready var starting_sliding_ray_cast_3d = $SlideNodes/StartingSlidingRayCast3D

# Return the desired direction of movement for the player via a
# Vector2 that contains a horizontal direction vector.
func get_movement_direction() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward").normalized()

# Return a boolean indicating if the player wants to jump
func wants_jump() -> bool:
	return Input.is_action_just_pressed('jump')

func wants_climb() -> bool:
	ledge_detection_ray_cast_3d.enabled = true
	ledge_detection_ray_cast_3d.force_raycast_update()
	
	if Input.is_action_pressed("jump") and ledge_detection_ray_cast_3d.is_colliding():
		ledge_detection_ray_cast_3d.enabled = false
		return true
	else:
		ledge_detection_ray_cast_3d.enabled = false
		return false

func wants_slide() -> bool:
	starting_sliding_ray_cast_3d.enabled = true
	starting_sliding_ray_cast_3d.force_raycast_update()
	
	var floor_normal = starting_sliding_ray_cast_3d.get_collision_normal()
	var input_dir = get_movement_direction()
	
	if Input.is_action_pressed("crouch") and starting_sliding_ray_cast_3d.is_colliding() and (player.velocity.length() >= speed_required_for_slide and input_dir.y < 0 or floor_normal.y < steepness_for_slide):
		starting_sliding_ray_cast_3d.enabled = false
		return true
	else:
		starting_sliding_ray_cast_3d.enabled = false
		return false
