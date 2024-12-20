extends Camera3D

var strafe_tilt_strength = 2.0
var strafe_tilt_speed_multiplier = 5.0
var fov_buildup = 0.0

@onready var player: CharacterBody3D = get_parent()

func tilt_camera(input_dir: Vector2, is_sprinting: bool, is_sliding: bool, delta: float):
	if input_dir.x > 0.0 or input_dir.x < 0.0:
		# lerp angle to be 0.0 when switching movement directions
		if rotation_degrees.z != 0.0:
			rotation_degrees.z = lerp_angle(rotation_degrees.z, 0.0, 0.1)
		rotation_degrees.z = lerp_angle(rotation_degrees.z, -input_dir.x * strafe_tilt_strength, delta * strafe_tilt_speed_multiplier)
	else:
		rotation_degrees.z = lerp_angle(rotation_degrees.z, 0.0, 0.1)
	
	if is_sliding:
		if is_equal_approx(fov, 95.0):
			fov_buildup = 0.0
		fov_buildup += delta * 0.0125
		if fov_buildup > 0.7:
			fov_buildup = 0.7
		fov = lerpf(fov, 95.0, 0.3 + fov_buildup)
	else:
		if is_equal_approx(fov, 80.0):
			fov_buildup = 0.0
		fov_buildup += delta * 0.0125
		if fov_buildup > 0.7:
			fov_buildup = 0.7
		fov = lerp(fov, 80.0, 0.3 + fov_buildup)
