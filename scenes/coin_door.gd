extends StaticBody2D

@export var player: PlayerController


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.coins > 49:
		queue_free()
