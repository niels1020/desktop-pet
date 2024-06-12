extends Node2D

@onready var poly = $poly
@export var size:Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var window = get_window()
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

	window.size = size
	window.position = Vector2i(100,100)
	var i:Image = DisplayServer.screen_get_image(0)
	
func get_mouse_pos():
	return Vector2(Vector2i(get_global_mouse_position())+get_window().position)
