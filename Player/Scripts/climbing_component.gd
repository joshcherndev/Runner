class_name ClimbingComponent
extends Node3D

@onready var above_ledge_ray_cast_3d = $AboveLedgeRayCast3D
@onready var ledge_detection_ray_cast_3d = $LedgeDetectionRayCast3D
@onready var climbing_timer = $ClimbingTimer
@onready var vaulting_path_3d = $VaultingPath3D
@onready var vaulting_path_follow_3d = $VaultingPath3D/VaultingPathFollow3D
@onready var vaulting_remote_transform_3d = $VaultingPath3D/VaultingPathFollow3D/VaultingRemoteTransform3D

@export var climb_speed = 5.0
@export var climbing_buildup = 0.0
@export var climbing_buildup_amount = 0.01
@export var climbing_range = 1.0
@export var climbing_jump_force = 10.0
var is_climbing = false
var can_climb = true
var can_climb_and_landed = true

@export var vault_speed = 0.04
var vault_progress = 0.0
var is_vaulting = false
var update_position = false

var collision_normal = Vector3.ZERO

@onready var player_mover = get_parent()
@onready var player: CharacterBody3D = player_mover.get_parent()

signal disable_jump
signal enable_jump

var debug = false

func _ready():
	climbing_timer.timeout.connect(enable_climbing)

func _process(delta):
	if debug:
		if can_climb:
			if player.is_on_floor():
				can_climb_and_landed = true
				enable_climbing()
		
		if is_vaulting:
			vault_over_ledge()
		
		# climbing
		if Input.is_action_pressed("jump"):
			climb()
		
		# jumping from climbing
		if Input.is_action_just_released("jump"):
			jump_from_climb()

func climb():
	if !player.is_on_ceiling()  and can_climb_and_landed:
		ledge_detection_ray_cast_3d.enabled = true
		ledge_detection_ray_cast_3d.force_raycast_update()
		
		# check if the player can climb
		if ledge_detection_ray_cast_3d.is_colliding():
			collision_normal = ledge_detection_ray_cast_3d.get_collision_normal()
			is_climbing = true
			
			above_ledge_ray_cast_3d.enabled = true
			above_ledge_ray_cast_3d.force_raycast_update()
			
			# keep climbing until exceeded range or reach the ledge
			
			# once player has climbed a max range, disable climbing
			# check if the player has reached the top of the wall to vault over
			if !above_ledge_ray_cast_3d.is_colliding():
				is_vaulting = true
				update_position = true
				disable_climbing()
			elif climbing_buildup > climbing_range:
				climbing_buildup = 0.0
				player.velocity.y = 0.0
				disable_climbing()
			else:
				player.velocity.y = climb_speed - climbing_buildup * 2.0
				climbing_buildup += climbing_buildup_amount
			
			above_ledge_ray_cast_3d.enabled = false
		
		ledge_detection_ray_cast_3d.enabled = false

func vault_over_ledge():
	if update_position:
		vaulting_path_3d.position = player.global_position
		vaulting_path_3d.rotation = player.rotation
		#player_mover.disable_jump()
		update_position = false
	if vaulting_path_follow_3d.progress_ratio >= 1.0:
		is_vaulting = false
		vault_progress = 0.0
		vaulting_path_follow_3d.progress_ratio = 0.0
		#player_mover.enable_jump()
	
	vaulting_path_follow_3d.progress_ratio += vault_speed
	player.global_position = vaulting_remote_transform_3d.global_position

func jump_from_climb():
	if is_climbing:
		# calculate the normal instead of the opposite vector
		player.velocity.y += climbing_jump_force * 0.25
		disable_climbing()

func disable_climbing():
	is_climbing = false
	can_climb = false
	can_climb_and_landed = false
	climbing_timer.start()

func enable_climbing():
	can_climb = true
