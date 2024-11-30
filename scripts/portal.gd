extends Area2D

var timer: int = 30

var portal_destination: Node2D
var portal_sprite: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	portal_destination = get_node("Portal Destination")
	portal_sprite = get_node("Sprite")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	timer -= 1
	if timer < 0:
		timer = 30
		portal_sprite.rotation_degrees += 90
		
	for body in get_overlapping_bodies():
		if body is PlayerController:
			body.position = portal_destination.global_position
