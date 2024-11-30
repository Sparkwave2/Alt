extends CharacterBody2D
class_name Enemy

var movement_vector: Vector2
var speed: float
@export var sprite: Sprite2D
@export var speed_mult: float = 1
@export var distance_mult: float = 1
var smoothing: float
var jumpiness: int
var jumpphase: int
var jump_cooldown: int = 0
@export var is_jumping = false

var ai_moves_left = true
var ai_move_timer: int = 120 * distance_mult

func _ready():
	ai_move_timer = 120 * distance_mult


func _process(delta):
	if jump_cooldown > 0:
		smoothing = 1
	elif ai_moves_left:
		movement_vector = Vector2(-0.5 * speed_mult, 0)
		sprite.flip_h = true
		smoothing = 0.2
	else:
		movement_vector = Vector2(0.5 * speed_mult, 0)
		sprite.flip_h = false
		smoothing = 0.2
		
func _physics_process(delta):
	
	if ai_move_timer <= 0:
		ai_move_timer = 120 * distance_mult
		ai_moves_left = !ai_moves_left
		
	ai_move_timer -= 1
	
	jump_cooldown -= 1
	
	# Reset jumpiness when on floor, and also set jumpphase to 0
	if is_on_floor():
		jumpiness = 10
		jumpphase = 0
	else:
		jumpiness -= 1
		
	# Do a jump based on the jumpiness
	if is_jumping and jumpiness > 0:
		velocity.y += -100
		
	# Also reset the jumpphase while holding jump, after already having checked it
	if is_jumping and jumpiness > 0:
		jumpphase = 1
		
	# If hit the ceiling with your head, stop ascending immediately
	if is_on_ceiling():
		jumpiness = 0
		velocity.y = 0
		
	# Disable falling while jumpiness is above zero, to simulate coyote time
	if velocity.y > 0 and jumpiness > 0 and !is_on_wall_only:
		velocity.y = 0
		
	# Apply gravity
	velocity.y += 400 * delta
	
	# Apply player movement
	velocity.x = velocity.x + ((movement_vector.x * 50) - velocity.x) * smoothing
	
	# Clamp speed
	velocity = velocity.clamp(Vector2(-100, -100), Vector2(100, 100))
	
	# Actually move the character
	move_and_slide()


func _on_area_2d_body_entered(body):
	if body is PlayerController:
		body.kill_player()
