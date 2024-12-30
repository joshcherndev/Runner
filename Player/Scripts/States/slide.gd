extends State

@export var idle_state: State
@export var grounded_crouch_state: State
@export var jump_state: State

@export var speed_required_for_slide: float = 10.0
@onready var sliding_stamina: float = 1.0
@export var sliding_stamina_cost: float = 0.025
@export var max_sliding_speed = 14.0
@export var sliding_accel = 4.0
@onready var sliding_drag = sliding_accel / max_sliding_speed

@onready var sliding_ray_cast_3d = $SlidingRayCast3D

func exit() -> void:
	sliding_stamina = 1.0

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_released("crouch"):
		return idle_state
	if parent.is_on_floor() and Input.is_action_just_pressed("jump") and sliding_stamina < 0.35:
		return jump_state
	
	return null

func process_physics(delta: float) -> State:
	if not parent.is_on_floor():
		# 0.5 for not dropping off of ledges too fast
		parent.velocity.y -= 0.5 * gravity * delta
	
	var new_state = _handle_slide(delta)
	if new_state:
		return new_state
	parent.move_and_slide()
	
	return null

func _handle_slide(delta: float) -> State:
	sliding_ray_cast_3d.enabled = true
	sliding_ray_cast_3d.force_raycast_update()
	
	if sliding_ray_cast_3d.is_colliding():
		var ground_normal = sliding_ray_cast_3d.get_collision_normal()
		var flat_velo = parent.velocity
		flat_velo.y = 0.0
		var input_dir = get_movement_input()
		var move_dir = parent.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
		
		# For slopes
		if ground_normal.y <= 0.9:
			parent.velocity += Vector3(ground_normal.x, 0, ground_normal.z) * 0.05 + (move_dir * 0.4)
		# For flat-ish ground
		elif ground_normal.y > 0.9:
			parent.velocity += ((sliding_accel * move_dir_entering_state) - (flat_velo * sliding_drag) + (move_dir * 0.4)) * sliding_stamina
			sliding_stamina -= sliding_stamina_cost
		
		if sliding_stamina <= 0.0:
			# Stop slide, go to grounded crouch
			sliding_ray_cast_3d.enabled = false
			return grounded_crouch_state
	
	sliding_ray_cast_3d.enabled = false
	
	return null
