extends GPUParticles2D

@export var player: PlayerController


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	emitting = player.is_liquid
	if player.is_liquid:
		position = player.position.snapped(Vector2(1, 1))
