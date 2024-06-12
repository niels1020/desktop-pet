extends Node2D

var cache = OS.get_cache_dir() + "/mds.desktop pet"
@export var size:Vector2i
@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var window = get_window()
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

	window.size = size
	window.position = Vector2i(100,100)
	get_landing_spots()


func get_mouse_pos():
	return Vector2(Vector2i(get_global_mouse_position())+get_window().position)


func get_landing_spots():
	DirAccess.make_dir_recursive_absolute(cache)
	OS.execute(OS.get_user_data_dir()+"/recognizer.exe", [])
	var file = FileAccess.open(cache + "window pos.txt",FileAccess.READ)
	if file.get_as_text() == "":
		print(file.get_open_error())
	var content = file.get_as_text()
	print(content)
	
	

