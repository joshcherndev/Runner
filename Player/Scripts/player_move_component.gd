extends Node3D

@export var speed_required_for_slide: float = 16.0
@export var steepness_for_slide: float = 0.925

@onready var player = get_parent()

@onready var ledge_detection_ray_cast_3d = $ClimbNodes/LedgeDetectionRayCast3D
@onready var starting_sliding_ray_cast_3d = $SlideNodes/StartingSlidingRayCast3D

const MAX_STEP_HEIGHT = 0.45
var snapped_to_stairs_last_frame := false
var last_frame_was_on_floor = -INF
var snapped_to_floor = false

@onready var stairs_ahead_ray_cast_3d = $StairsNodes/StairsAheadRayCast3D
@onready var stairs_below_ray_cast_3d = $StairsNodes/StairsBelowRayCast3D
@onready var stair_smoothing_remote_transform_3d: RemoteTransform3D = $StairsNodes/StairSmoothingRemoteTransform3D

## PLAYER INPUT HANDLING

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

## PLAYER MOVEMENT CORRECTIONS

func process_movement_with_correction(delta):
	if player.is_on_floor(): 
		last_frame_was_on_floor = Engine.get_physics_frames()
	
	if not snap_up_stairs_check(delta):
		# snap_up_stairs_check moves the player manually, so don't call move_and_slide.
		# should be fine as we ensure with body_test_motion that the player doesn't collide
		# with anything except the stair its moving up to.
		player.move_and_slide() 
		snap_down_to_stairs_check()
	
	snapped_to_floor = snapped_to_stairs_last_frame
	_slide_camera_back_to_origin(delta)

func run_body_test_motion(from: Transform3D, motion: Vector3, result = null) -> bool:
	if not result: result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(player.get_rid(), params, result)

var _saved_camera_global_pos = null
func _save_camera_pos_for_smoothing() -> void:
	if _saved_camera_global_pos == null:
		_saved_camera_global_pos = stair_smoothing_remote_transform_3d.global_position

func _slide_camera_back_to_origin(delta: float) -> void:
	if _saved_camera_global_pos == null: return
	stair_smoothing_remote_transform_3d.global_position.y = _saved_camera_global_pos.y
	# Clamp camera smoothing position in case of player teleport
	stair_smoothing_remote_transform_3d.position.y = clampf(stair_smoothing_remote_transform_3d.position.y, -0.7, 0.7)
	# 10.0 placeholder for default move_speed for player
	var move_amount = max(player.velocity.y * delta, 10.0 / 2.0 * delta)
	stair_smoothing_remote_transform_3d.position.y = move_toward(stair_smoothing_remote_transform_3d.position.y, 0.0, move_amount)
	_saved_camera_global_pos = stair_smoothing_remote_transform_3d.global_position
	if stair_smoothing_remote_transform_3d.position.y == 0:
		# Stop smoothing camera null
		_saved_camera_global_pos = null

func snap_down_to_stairs_check():
	var did_snap := false
	
	stairs_below_ray_cast_3d.enabled = true
	stairs_below_ray_cast_3d.force_raycast_update()
	var floor_below : bool = stairs_below_ray_cast_3d.is_colliding() and not is_surface_too_steep(stairs_below_ray_cast_3d.get_collision_normal())
	stairs_below_ray_cast_3d.enabled = false
	
	var was_on_floor_last_frame = Engine.get_physics_frames() - last_frame_was_on_floor == 1
	if not player.is_on_floor() and player.velocity.y <= 0 and (was_on_floor_last_frame or snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if run_body_test_motion(player.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_result):
			_save_camera_pos_for_smoothing()
			var translate_y = body_test_result.get_travel().y
			player.position.y += translate_y
			player.apply_floor_snap()
			did_snap = true
			print("snapped down")
	snapped_to_stairs_last_frame = did_snap

func snap_up_stairs_check(delta) -> bool:
	if not player.is_on_floor() and not snapped_to_stairs_last_frame: 
		return false
	# Don't snap stairs if trying to jump, also no need to check for stairs ahead if not moving
	if player.velocity.y > 0 or (player.velocity * Vector3(1, 0, 1)).length() == 0:
		return false
	var expected_move_motion = player.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = player.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	var down_check_result = PhysicsTestMotionResult3D.new()
	if (run_body_test_motion(step_pos_with_clearance, Vector3(0, -MAX_STEP_HEIGHT * 2, 0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - player.global_position).y
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_collision_point() - player.global_position).y > MAX_STEP_HEIGHT: return false
		stairs_ahead_ray_cast_3d.global_position = down_check_result.get_collision_point() + Vector3(0,MAX_STEP_HEIGHT,0) + expected_move_motion.normalized() * 0.1
		
		stairs_ahead_ray_cast_3d.enabled = true
		stairs_ahead_ray_cast_3d.force_raycast_update()
		if stairs_ahead_ray_cast_3d.is_colliding() and not is_surface_too_steep(stairs_ahead_ray_cast_3d.get_collision_normal()):
			_save_camera_pos_for_smoothing()
			player.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			player.apply_floor_snap()
			snapped_to_stairs_last_frame = true
			print("snapped up")
			stairs_ahead_ray_cast_3d.enabled = false
			return true
	stairs_ahead_ray_cast_3d.enabled = false
	return false

func is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > player.floor_max_angle
