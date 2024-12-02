extends Area2D

var hitbox: CollisionShape2D

@export var player: PlayerController

@export var bad_ending: PackedScene
@export var good_ending: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	hitbox = get_node("CollisionShape2D")
	hitbox.disabled = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.f1_unlocked and Input.is_physical_key_pressed(KEY_PERIOD) and Input.is_physical_key_pressed(KEY_COMMA) and Input.is_physical_key_pressed(KEY_SPACE) and Input.is_physical_key_pressed(KEY_LEFT) and Input.is_action_pressed("rightalt") and Input.is_action_pressed("windowskey"):
		show()
		hitbox.disabled = false
		
	for body in get_overlapping_bodies():
		if body is PlayerController:
			if player.f1_unlocked:
				get_tree().change_scene_to_packed(bad_ending)
			else:
				get_tree().change_scene_to_packed(good_ending)
