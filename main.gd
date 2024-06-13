extends Node2D

var cache = OS.get_cache_dir() + "/mds.desktop pet"
@export var size:Vector2
@onready var sprite = $AnimatedSprite2D
@onready var man = $man
var state = 0
var target:Vector2
@export var speed = 50


# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().size = size
	


# Called every frame. 'delta' is the elapsed time since the previous frame.




func get_mouse_pos():
	return Vector2(Vector2i(get_global_mouse_position())+get_window().position)


func get_landing_spots():
	var rect:Rect2
	if man.data is Rect2:
		rect = man.data
	
	var positions = []
	for i in rect.size.x - size.x:
		positions += [Vector2(i+rect.position.x,rect.position.y-size.y)]
	
	return positions



func _process(delta):
	await get_tree().process_frame
	var velocity = Vector2()
	var window = get_window()
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

	
	if state == 0:
		get_landing_spots().pick_random()
		state = 1
		sprite.play("take of")
		velocity = Vector2(window.position).direction_to(target) * speed
	elif state == 1:
		if Vector2i(target) == window.position:
			state = 2
		else:
			await sprite.animation_looped
			sprite.play("flying")
			velocity = Vector2(window.position).direction_to(target) * speed
			
	
	window.position += Vector2i(velocity*delta)
	sprite.flip_h = velocity.x < 0
	
