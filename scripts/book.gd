extends Area2D
class_name Book

@export_multiline var book_text = "The legend says:\nHere's some fun stuff!"
enum BookKind {GREEN, BLUE, RED, YELLOW}
@export var book_kind: BookKind = BookKind.GREEN

@export var green_texture: Texture2D
@export var red_texture: Texture2D
@export var blue_texture: Texture2D
@export var yellow_texture: Texture2D

var sprite: Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = get_node("BookSprite")
	match book_kind:
		BookKind.GREEN:
			sprite.texture = green_texture
		BookKind.BLUE:
			sprite.texture = blue_texture
		BookKind.RED:
			sprite.texture = red_texture
		BookKind.YELLOW:
			sprite.texture = yellow_texture
			
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body is PlayerController:
		body.on_book = true
		body.book_text.text = book_text
		body.current_book_kind = book_kind
		body.book_text.text += "\n[right]Release 9 to close."
		body.book_text_hi_res.text = book_text.replace("tiny", "tin").replace("font_size=6", "font_size=19")
		body.book_text_hi_res.text += "\n[right]Release 9 to close."


func _on_body_exited(body):
	if body is PlayerController:
		body.on_book = false
