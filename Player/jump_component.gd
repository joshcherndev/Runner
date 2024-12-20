class_name JumpComponent
extends Node3D

@export var jump_force = 10.0

var disabled = false

@onready var player_mover = get_parent()
@onready var player: CharacterBody3D = player_mover.get_parent()

func _process(delta):
	# jumping
	if !disabled and Input.is_action_just_pressed("jump"):
		jump()

func jump():
	if player.is_on_floor() or player_mover.snapped_to_floor:
		player.velocity.y += jump_force
