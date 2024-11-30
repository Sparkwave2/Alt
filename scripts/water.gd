extends Area2D

@export var honey: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body is PlayerController:
		body.in_water = true
		if body.is_liquid and !honey:
			body.kill_player()


func _on_body_exited(body):
	if body is PlayerController:
		body.in_water = false
