extends StaticBody2D

var player: PlayerController
var hitbox: CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_node("Player")
	hitbox = get_node("CollisionShape2D")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.is_liquid:
		hitbox.disabled = true
	else:
		hitbox.disabled = false
