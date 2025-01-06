extends State

# States that are possible to transition to from climb.
@export var idle_state: State
@export var walk_state: State
@export var sprint_state: State
@export var jump_state: State
@export var fall_state: State
@export var grounded_crouch_state: State
@export var mid_air_crouch_state: State

@onready var above_ledge_ray_cast_3d = $AboveLedgeRayCast3D
@onready var climbing_timer = $ClimbingTimer
@onready var vaulting_path_3d = $VaultingPath3D
@onready var vaulting_path_follow_3d = $VaultingPath3D/VaultingPathFollow3D
@onready var vaulting_position = $VaultingPath3D/VaultingPathFollow3D/VaultingPosition

@export var climb_speed = 5.0
@export var climbing_buildup = 0.0
@export var climbing_buildup_amount = 0.01
@export var climbing_range = 1.0
var is_climbing = false
var can_climb = true
var can_climb_and_landed = true

@export var vault_speed = 0.04
var is_vaulting = false
var update_position = false

func _ready():
	climbing_timer.timeout.connect(enable_climbing)

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_released("jump"):
		return jump_state
	
	return null

func process_physics(delta: float) -> State:
	if not parent.is_on_floor():
		parent.velocity.y -= gravity * delta
	
	# Check if player can climb, update climbing progress.
	if not is_vaulting:
		var new_state = _climb()
		if new_state: 
			return new_state
	# Once player beginds vaulting, update their position once every physics frame.
	else:
		var new_state = _vault_over_ledge()
		if new_state: 
			return new_state
	
	return null

func _climb():
	# If can climb and not on ceiling, check that they are in climbing range.
	if not parent.is_on_ceiling() and can_climb:
		above_ledge_ray_cast_3d.enabled = true
		above_ledge_ray_cast_3d.force_raycast_update()
		
		## Keep climbing until exceeded range or reach the ledge.
		
		# Check if the player has reached the top of the wall to vault over.
		if not above_ledge_ray_cast_3d.is_colliding():
			is_vaulting = true
			update_position = true
			disable_climbing()
		
		# Once player has climbed a max range, disable climbing.
		elif climbing_buildup > climbing_range:
			climbing_buildup = 0.0
			parent.velocity.y = 0.0
			disable_climbing()
		else:
			parent.velocity.y = climb_speed - climbing_buildup * 2.0
			climbing_buildup += climbing_buildup_amount
		
		above_ledge_ray_cast_3d.enabled = false
	
	return null

func _vault_over_ledge() -> State:
	# Update where the vaulting path's position is on vaulting start-up.
	if update_position:
		vaulting_path_3d.position = parent.global_position
		vaulting_path_3d.rotation = parent.rotation
		update_position = false
	if vaulting_path_follow_3d.progress_ratio >= 1.0:
		is_vaulting = false
		vaulting_path_follow_3d.progress_ratio = 0.0
		
		#if parent.is_on_floor() and Input.is_action_pressed("crouch"):
			#return grounded_crouch_state
		#
		#var move_dir = get_movement_input()
		#if move_dir.length() != 0.0 and Input.is_action_pressed("sprint"):
			#return sprint_state
		#elif move_dir.length() != 0.0:
			#return walk_state
		#
		#if not parent.is_on_floor() and Input.is_action_pressed("crouch"):
			#return mid_air_crouch_state
		#elif not parent.is_on_floor():
			#return fall_state
		
		return idle_state
	vaulting_path_follow_3d.progress_ratio += vault_speed
	parent.global_position = vaulting_position.global_position
	
	return null

func disable_climbing():
	is_climbing = false
	can_climb = false
	can_climb_and_landed = false
	climbing_timer.start()

func enable_climbing():
	can_climb = true
