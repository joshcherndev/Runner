class_name StairsComponent
extends Node3D

const MAX_STEP_HEIGHT = 0.5
var snapped_to_stairs_last_frame := false
var last_frame_was_on_floor = -INF

@onready var player_mover = get_parent()
@onready var player: CharacterBody3D = player_mover.get_parent()
@onready var stairs_ahead_ray_cast_3d = %StairsAheadRayCast3D
@onready var stairs_below_ray_cast_3d = %StairsBelowRayCast3D

func _physics_process(delta):
	if player.is_on_floor(): 
		last_frame_was_on_floor = Engine.get_physics_frames()

func run_body_test_motion(from: Transform3D, motion: Vector3, result = null) -> bool:
	if not result: result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(player.get_rid(), params, result)

func snap_down_to_stairs_check():
	var did_snap := false
	
	stairs_below_ray_cast_3d.enabled = true
	stairs_below_ray_cast_3d.force_raycast_update()
	var floor_below : bool = stairs_below_ray_cast_3d.is_colliding() and not player_mover.is_surface_too_steep(stairs_below_ray_cast_3d.get_collision_normal())
	stairs_below_ray_cast_3d.enabled = false
	
	var was_on_floor_last_frame = Engine.get_physics_frames() - last_frame_was_on_floor == 1
	if not player.is_on_floor() and player.velocity.y <= 0 and (was_on_floor_last_frame or snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if run_body_test_motion(player.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			player.position.y += translate_y
			player.apply_floor_snap()
			did_snap = true
			print("snapped down")
	snapped_to_stairs_last_frame = did_snap

func snap_up_stairs_check(delta) -> bool:
	if not player.is_on_floor() and not snapped_to_stairs_last_frame: 
		return false
	# Allows player to jump while walking up stairs and slopes instead of snapping up
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
		if stairs_ahead_ray_cast_3d.is_colliding() and not player_mover.is_surface_too_steep(stairs_ahead_ray_cast_3d.get_collision_normal()):
			player.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			player.apply_floor_snap()
			snapped_to_stairs_last_frame = true
			print("snapped up")
			stairs_ahead_ray_cast_3d.enabled = false
			return true
	stairs_ahead_ray_cast_3d.enabled = false
	return false
