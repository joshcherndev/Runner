extends Camera3D

var strafe_tilt_strength = 2.0
var strafe_tilt_speed_multiplier = 5.0

@onready var player: CharacterBody3D = get_parent()

func tilt_camera(input_dir: Vector2, delta: float):
	if input_dir.x > 0.0 or input_dir.x < 0.0:
		# lerp angle to be 0.0 when switching movement directions
		if rotation_degrees.z != 0.0:
			rotation_degrees.z = lerp_angle(rotation_degrees.z, 0.0, 0.1)
		rotation_degrees.z = lerp_angle(rotation_degrees.z, -input_dir.x * strafe_tilt_strength, delta * strafe_tilt_speed_multiplier)
	else:
		rotation_degrees.z = lerp_angle(rotation_degrees.z, 0.0, 0.1)
