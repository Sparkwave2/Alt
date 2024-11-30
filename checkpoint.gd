extends StaticBody2D
class_name Checkpoint

@export var checkpoint_id: int

var player: PlayerController

var particle_emitter: GPUParticles2D

var is_active: bool = false

var sprite_inactive: Sprite2D
var sprite_active: Sprite2D

var timer: int

var timer_reset: int = 30


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_inactive = get_node("SpriteInactive")
	sprite_active = get_node("SpriteActive")
	
	player = get_parent().get_node("Player")
	
	particle_emitter = get_node("GPUParticles2D")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("respawn"):
		if is_active:
			player.position = position
			player.dead = false
			player.death_particles.position = position
			player.death_particles.restart()
			player.death_particles.emitting = true
			player.sprite.show()
			player.death_text.hide()
			
	
func _physics_process(delta):
	if timer <= 0:
		if is_active:
			sprite_active.show()
			sprite_inactive.hide()
			if sprite_active.frame == 2:
				sprite_active.frame = 0
			else:
				sprite_active.frame += 1
			timer = 15
		else:
			sprite_inactive.show()
			sprite_active.hide()
			if sprite_inactive.frame == 2:
				sprite_inactive.frame = 0
			else:
				sprite_inactive.frame += 1
			timer = 30
			
	if player.checkpoint == checkpoint_id:
		is_active = true
	else:
		is_active = false
		
	timer -= 1
	


func _on_area_2d_body_entered(body):
	if body is PlayerController:
		body.checkpoint = checkpoint_id
		if !is_active:
			particle_emitter.emitting = true
			player.checkpoint_sound.play()
		
