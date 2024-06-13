extends Camera2D

@onready var platform_destroyer = $Destroyer
@onready var platform_destroyer_shape = $Destroyer/CollisionShape2D

var viewport_size
var player: Player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_size = get_viewport_rect().size
	# get the width of the viewport
	# and set the X position of the camera to half of the viewport width
	global_position.x = viewport_size.x / 2
	# keep the camera moving past the bottom of the viewport
	# by setting the limit bottom (limit_bottom) property
	limit_bottom = viewport_size.y
	limit_left = 0
	limit_right = viewport_size.x
	
	# position the platform destroyer relative and fixed below the camera
	# so that when the player and camera move up and platforms fall out of view
	# they are removed from the game resources efficiently
	platform_destroyer.position.y = viewport_size.y
	var rect_shape = RectangleShape2D.new()
	var rect_shape_size = Vector2(viewport_size.x, 200)
	rect_shape.set_size(rect_shape_size)
	platform_destroyer_shape.shape = rect_shape

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# keep resetting the camera bottom limit based on how high we have currently jumped
	var limit_distance = 419 #keep the limit below the player
	if player:
		if limit_bottom > player.global_position.y + limit_distance:
			limit_bottom = int(player.global_position.y) + limit_distance
	
	var overlapping_areas = platform_destroyer.get_overlapping_areas()
	if overlapping_areas.size() > 0:
		for overlapping_area in overlapping_areas:
			if overlapping_area is Platform:
				overlapping_area.queue_free()
			
	
func _physics_process(_delta):
	if player != null:
		# set the camera (this) global_position y position = the non-null player global_position.y value
		global_position.y = player.global_position.y

func setup_camera(_player:Player):
	# if the _player variable is not null
	if _player:
		player = _player
