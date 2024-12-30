class_name State
extends Node3D

@export var animation_name: String

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir_entering_state: Vector3

var animations: AnimationPlayer
var move_component
var parent: CharacterBody3D

func enter() -> void:
	animations.play(animation_name)
	var input_dir = get_movement_input()
	move_dir_entering_state = parent.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	return null

func get_movement_input() -> Vector2:
	return move_component.get_movement_direction()

func get_jump() -> bool:
	return move_component.wants_jump()

func get_climb() -> bool:
	return move_component.wants_climb()

func get_slide() -> bool:
	return move_component.wants_slide()
