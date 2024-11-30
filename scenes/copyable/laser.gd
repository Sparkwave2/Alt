extends Area2D
class_name Laser

var leftwards: bool = false
var player: PlayerController
var lifetime = 1800


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if leftwards:
		position.x -= 1
	else:
		position.x += 1

	for enemy in get_overlapping_bodies():
		if enemy is Enemy:
			enemy.queue_free()
			player.whoops_sound.play()
			queue_free()
		elif enemy is PlayerController:
			pass
		elif enemy is IceBlock:
			enemy.queue_free()
			queue_free()
		else:
			queue_free()
	
	lifetime -= 1
	if lifetime < 0:
		queue_free()
