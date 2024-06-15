extends Node2D

var cache = OS.get_cache_dir() + "/mds.desktop pet"
@export var size:Vector2
@onready var sprite = $CharacterBody2D/AnimatedSprite2D
@onready var bird = $CharacterBody2D

var state = 0
var target:Vector2
@export var speed = 100
@onready var man = $man
@onready var audio = $audio

# Called when the node enters the scene tree for the first time.
func _ready():
	bird.position = get_window().size / 2
	ApiManager.SetClickThrough(true)


func get_landing_spots():
	var rect:Rect2
	if man.get_data() != null:
		rect = man.get_data()
	else:
		@warning_ignore("narrowing_conversion")
		rect = Rect2(Vector2(size.x+1,size.y+1),Vector2i(size.x+1,size.y+1))
	
	var positions = []
	for i in rect.size.x - size.x:
		var pos = Vector2((rect.position.x+i)+(size.x/2),rect.position.y-size.y)
		var screen_size = get_viewport_rect().size

		
		if pos.y < 0 or pos.y > screen_size.y:
			pos.y = screen_size.y - size.y - 50
		
		if pos.x < 0 or pos.x > screen_size.x:
			pass
		else:
			positions += [pos]
	return positions



func _process(_delta):
	if state == 1:
		bird.velocity = bird.position.direction_to(target) * speed
	if man.get_data() != null:
		
		if Input.is_action_just_pressed("escape"):
			get_tree().quit()
		
		
		#$Line.points = PackedVector2Array(get_landing_spots())
		#$Line.add_point(target)
		#$Line.add_point(bird.position)
		
		
		if state == 0:
			target = get_landing_spots().pick_random()
			state = 1
			sprite.play("take of")
			await sprite.animation_looped
			sprite.play("flying")
		elif state == 1:
			bird.velocity = bird.position.direction_to(target) * speed
			state = 2
		elif state == 2:
			if bird.position.distance_to(target) < 10:
				if !get_landing_spots().has(target):
					target = get_landing_spots().pick_random()
					state = 1
				else:
					sprite.play("landing")
					bird.position = target
					bird.velocity = Vector2(0,0)
					state = 3
		elif state == 4:
			if !get_landing_spots().has(target):
				if target.y == get_window().size.y - size.y:
					state = 0
				else:
					target = get_landing_spots().pick_random()
					state = 1
					sprite.play("flying")
			else:
				if randi_range(0,50) == 1:
					audio.play()
					sprite.play("crowing")
					await sprite.animation_looped
					sprite.play("idle")
	bird.move_and_slide()
	sprite.flip_h = bird.velocity.x < 0



func _on_animated_sprite_2d_animation_looped():
	if state == 3:
		bird.velocity = Vector2(0,0)
		state = 4
		sprite.play("idle")
