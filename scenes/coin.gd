extends Area2D

var timer = 30

var sprite: Sprite2D

var collider: CollisionShape2D

var player: PlayerController


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = get_node("Sprite2D")
	collider = get_node("StaticBody2D/CollisionShape2D")
	player = get_parent().get_parent().get_node("Player")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	
	if timer < 0:
		if sprite.frame == 1:
			sprite.frame = 0
		else:
			sprite.frame = 1
		timer = 30
	timer -= 1
	
	if player.is_wallet_open:
		for body in get_overlapping_bodies():
			if body is PlayerController:
				body.coins += 1
				body.activate_sound.play()
				queue_free()
		collider.disabled = true
	else:
		collider.disabled = false
