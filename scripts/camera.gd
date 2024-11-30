extends Camera2D

@export var player: CharacterBody2D
var target_position: Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Set the target position to follow the player
	target_position = player.position
	# Snap the camera to the screen grid, including the offset of (80, 45)
	# and the distance between screens of (160, 90)
	# Let's keep it constant so that the screens are separate
	target_position.x = (round((target_position.x + 80) / 160) * 160) - 80
	target_position.y = (round((target_position.y + 48) / 96) * 96) - 48
	
	# Lerp out the camerae movement so that it appears smooth
	position = position.lerp(target_position, delta * 6)
