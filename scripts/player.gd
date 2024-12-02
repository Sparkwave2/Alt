extends CharacterBody2D
class_name PlayerController

@export var environment: TileMapLayer
@export var status_text: RichTextLabel
@export var death_text: RichTextLabel
@export var coin_text: RichTextLabel

@export var solid_sprite: Texture2D
@export var liquid_sprite: Texture2D
@export var meow_sprite: Texture2D
@export var liquid_fall_sprite: Texture2D

@export var book_ui: ColorRect
var book_text: RichTextLabel
var book_text_hi_res: RichTextLabel

var last_tile_touched: Vector2i
var last_tile_touched_pos: Vector2i
var tile: Vector2i

var movement_vector: Vector2
var speed: float
var sprite: Sprite2D
var light: PointLight2D
var smoothing: float
var jumpiness: int
var jumpphase: int
var in_water: bool = false
var on_ladder: bool = false
var in_darkness: bool = false
var jump_cooldown: int = 0
var is_light_active: bool = false
var is_wallet_open: bool = false
var status_text_duration: int = 0
var is_liquid: bool = false
var on_book: bool = false
var current_book_kind: Book.BookKind

var punch_unlocked: bool = false
var jump_unlocked: bool = false
var shoot_unlocked: bool = false
var f1_unlocked: bool = false

var typed_characters: String

var dead: bool = false
var checkpoint: int = 0

var jump_sound: AudioStreamPlayer
var activate_sound: AudioStreamPlayer
var whoops_sound: AudioStreamPlayer
var checkpoint_sound: AudioStreamPlayer

@export var death_particles: GPUParticles2D

@export var punch_particles_right: GPUParticles2D
@export var punch_particles_left: GPUParticles2D

var hitbox_right: Area2D
var hitbox_left: Area2D

@export var laser_scene: PackedScene

var coins: int = 0

var hiresfont: bool = false

var fullscreen: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = get_node("Sprite2D")
	light = get_node("PointLight2D")
	hitbox_right = get_node("HitboxRight")
	hitbox_left = get_node("HitboxLeft")
	book_text = book_ui.get_node("BookBackground").get_node("BookText")
	book_text_hi_res = book_ui.get_node("BookBackground").get_node("BookTextHiRes")
	death_text.hide()
	
	jump_sound = get_node("JumpSound")
	activate_sound = get_node("ActivateSound")
	whoops_sound = get_node("WhoopsSound")
	checkpoint_sound = get_node("CheckpointSound")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dead:
		movement_vector = Vector2(0, 0)
		smoothing = 0
	elif jump_cooldown > 0:
		smoothing = 1
	elif Input.is_physical_key_pressed(KEY_Q) and not Input.is_physical_key_pressed(KEY_E):
		movement_vector = Vector2(-1, 0)
		sprite.flip_h = true
		smoothing = 0.2
	elif Input.is_physical_key_pressed(KEY_E) and not Input.is_physical_key_pressed(KEY_Q):
		movement_vector = Vector2(1, 0)
		sprite.flip_h = false
		smoothing = 0.2
	else:
		movement_vector = Vector2(0, 0)
		smoothing = 0.1
		
		
	if is_liquid and !dead:
		smoothing = 0.04
		movement_vector *= 1.5
		
	# Make sure to always sync the flashlight
	if is_light_active and !dead:
		light.enabled = in_darkness
	else:
		light.enabled = false
		
	if on_book and Input.is_physical_key_pressed(KEY_9) and !dead:
		book_ui.show()
		match current_book_kind:
			Book.BookKind.GREEN:
				book_ui.color = Color("#009e00")
			Book.BookKind.RED:
				book_ui.color = Color.DARK_RED
			Book.BookKind.BLUE:
				book_ui.color = Color.MEDIUM_BLUE
			Book.BookKind.YELLOW:
				book_ui.color = Color.YELLOW
				
	else:
		book_ui.hide()
		
	coin_text.text = "[right]Coins: " + str(coins)
	if is_wallet_open:
		coin_text.show()
	else:
		coin_text.hide()
		
	if Input.is_action_just_pressed("fullscreen"):
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen = !fullscreen
		
	
func _physics_process(delta):
	
	if get_last_slide_collision():
		if get_last_slide_collision().get_collider_rid() != null:

			last_tile_touched = environment.get_cell_atlas_coords(
				environment.get_coords_for_body_rid(
					get_last_slide_collision().get_collider_rid()
				)
			)
			
			last_tile_touched_pos = environment.get_coords_for_body_rid(
				get_last_slide_collision().get_collider_rid()
			)
			
			tile = environment.get_cell_atlas_coords(
				environment.local_to_map(
					position
				)
			)
	
	jump_cooldown -= 1
	
	status_text_duration -= 1
	if status_text_duration < 0:
		status_text.hide()
	
	# Reset jumpiness when on floor, and also set jumpphase to 0
	if is_on_floor():
		if in_water:
			jumpiness = 20
		else:
			jumpiness = 10
		jumpphase = 0
	else:
		jumpiness -= 1
		
	# Water swimming
	if in_water and !dead:
		if Input.is_physical_key_pressed(KEY_CTRL) and Input.is_physical_key_pressed(KEY_U):
			jumpiness = 10
			velocity.y += -100
		
	# Do a jump based on the jumpiness
	if Input.is_physical_key_pressed(KEY_TAB) and jumpiness > 0 and !dead and jump_unlocked:
		velocity.y += -100
		if jumpiness == 10:
			jump_sound.play()
		
	# If jump was just pressed during coyote time, reset jumpiness to 10 just for now
	if Input.is_action_just_pressed("jump") and jumpiness > 0 and jumpphase == 0 and !dead and jump_unlocked:
		jumpiness = 10
		jumpphase = 1
		velocity.y = 0
		jump_sound.play()
		
	# Wall jump
	if is_on_wall_only():
		if Input.is_physical_key_pressed(KEY_SHIFT) and Input.is_physical_key_pressed(KEY_W) and !dead:
			jump_sound.play()
			jumpiness = 10
			jumpphase = 1
			jump_cooldown = 15
			# Single wall jump override
			if !Input.is_physical_key_pressed(KEY_0):
				if get_wall_normal().x > 0.1:
					movement_vector = Vector2(10, 0)
				if get_wall_normal().x < -0.1:
					movement_vector = Vector2(-10, 0)
			else:
				if get_wall_normal().x > 0.1:
					movement_vector = Vector2(0.5, 0)
				if get_wall_normal().x < -0.1:
					movement_vector = Vector2(-0.5, 0)
		
	# Also reset the jumpphase while holding jump, after already having checked it
	if Input.is_physical_key_pressed(KEY_TAB) and jumpiness > 0 and !dead and jump_unlocked:
		jumpphase = 1
		
	# If hit the ceiling with your head, stop ascending immediately
	if is_on_ceiling():
		jumpiness = 0
		velocity.y = 0
		
	# Disable falling while jumpiness is above zero, to simulate coyote time
	if velocity.y > 0 and jumpiness > 0 and !is_on_wall_only:
		velocity.y = 0
	
	# Ladder controls
	if on_ladder and !dead:
		if Input.is_physical_key_pressed(KEY_Z):
			if Input.is_physical_key_pressed(KEY_W):
				velocity.y = -50
			if Input.is_physical_key_pressed(KEY_S):
				velocity.y = 50
				
		if Input.is_physical_key_pressed(KEY_M):
			jumpiness = 10
			
	match last_tile_touched:
		# Coin
		Vector2i(5, 1):
			if is_wallet_open:
				environment.erase_cell(last_tile_touched_pos)
		
	# Apply gravity
	velocity.y += 400 * delta
	
	# Disable falling here once again when being on ladder and not climbing down
	if on_ladder and velocity.y > 0 and !(Input.is_physical_key_pressed(KEY_Z) and Input.is_physical_key_pressed(KEY_S)):
		velocity.y = 0
	
	# Apply player movement
	velocity.x = velocity.x + ((movement_vector.x * 50) - velocity.x) * smoothing
	
	# Clamp speed
	velocity = velocity.clamp(Vector2(-100, -100), Vector2(100, 100))
	
	# Reduce the speed if in water
	if in_water:
		velocity = velocity * 0.5
	
	# Actually move the character
	move_and_slide()
	
	# Increase the speed again after reducing it
	if in_water:
		velocity = velocity * 2
		
func _input(event):
	if Input.is_action_pressed("rightalt") and Input.is_physical_key_pressed(KEY_K) and Input.is_physical_key_pressed(KEY_L) and Input.is_action_just_pressed("light"):
		is_light_active = !is_light_active
		if is_light_active:
			display_status("Light On", Color.LIME_GREEN, 1)
			activate_sound.play()
		else:
			display_status("Light Off", Color.RED, 1)
			activate_sound.play()
		
	if Input.is_physical_key_pressed(KEY_BRACKETLEFT) and Input.is_physical_key_pressed(KEY_BRACKETRIGHT) and Input.is_action_pressed("leftshift") and Input.is_action_just_pressed("wallet"):
		is_wallet_open = !is_wallet_open
		if is_wallet_open:
			display_status("Wallet is now open", Color.LIME_GREEN, 1)
			activate_sound.play()
		else:
			display_status("Wallet is now closed", Color.RED, 1)
			activate_sound.play()
			
	if Input.is_action_just_pressed("liquid"):
		is_liquid = !is_liquid
		if is_liquid:
			sprite.texture = liquid_sprite
			activate_sound.play()
			display_status("Changed state to liquid", Color.BLUE, 1)
		else:
			sprite.texture = solid_sprite
			activate_sound.play()
			display_status("Changed state to solid", Color.DIM_GRAY, 1)
			
	if Input.is_action_just_pressed("punch") and punch_unlocked and !dead:
		punch()
		
	if Input.is_action_just_pressed("shoot") and shoot_unlocked and !dead:
		shoot()
			
	# Handling the typed characters variable
	if event is InputEventKey:
		if event.pressed:
			typed_characters += event.as_text_keycode()
			#print(typed_characters)
			if typed_characters.length() > 50:
				typed_characters = typed_characters.right(50)
				
	if typed_characters.ends_with("PINEAPPLES") and !punch_unlocked:
		display_status("Punch unlocked!", Color.LIME_GREEN, 1)
		activate_sound.play()
		punch_unlocked = true
		
	if typed_characters.ends_with("UPPIES") and !jump_unlocked:
		display_status("Jumping unlocked!", Color.LIME_GREEN, 1)
		activate_sound.play()
		jump_unlocked = true
		
	if typed_characters.ends_with("PEWPEWHAHAHA") and !shoot_unlocked:
		display_status("Laser unlocked!", Color.LIME_GREEN, 1)
		activate_sound.play()
		shoot_unlocked = true
		
	if typed_characters.ends_with("ILOVECATTREATS"):
		f1_unlocked = !f1_unlocked
		if f1_unlocked:
			display_status("F1 reactor enabled", Color.LIME_GREEN, 1)
			activate_sound.play()
		else:
			display_status("F1 reactor disabled", Color.RED, 1)
			activate_sound.play()
		typed_characters += "E"
		
	if Input.is_action_just_pressed("hiresfont"):
		hiresfont = !hiresfont
		
	if hiresfont:
		book_text.hide()
		book_text_hi_res.show()
	else:
		book_text.show()
		book_text_hi_res.hide()
		
		
		
func display_status(text: String, color: Color, duration: float):
	status_text.text = "[color=#"
	status_text.text += color.to_html(false)
	status_text.text += "]"
	status_text.text += text
	status_text_duration = duration * 60
	status_text.show()
	
func kill_player():
	dead = true
	sprite.hide()
	death_particles.restart()
	death_particles.emitting = true
	death_text.show()
	
func punch():
	if sprite.flip_h:
		punch_particles_left.restart()
		punch_particles_left.emitting = true
		print(hitbox_left.get_overlapping_bodies())
		for enemy in hitbox_left.get_overlapping_bodies():
			if enemy is Enemy:
				enemy.queue_free()
				whoops_sound.play()
				
	else:
		punch_particles_right.restart()
		punch_particles_right.emitting = true
		print(hitbox_right.get_overlapping_bodies())
		for enemy in hitbox_right.get_overlapping_bodies():
			if enemy is Enemy:
				enemy.queue_free()
				whoops_sound.play()
	
func shoot():
	var laser: Laser = laser_scene.instantiate()
	laser.leftwards = sprite.flip_h
	laser.player = self
	laser.position = position
	get_parent().add_child(laser)
