extends Node2D

var platform_scene = preload("res://scenes/platform.tscn")

@onready var platform_parent: Node2D = $PlatformParent

var y_distance_between_platforms
var generated_platform_count
var start_platform_y
var platform_height
var platform_width
var platform_count
var viewport_size
var player: Player = null

func setup(_player:Player):
	if _player:
		player = _player

func _ready():
	viewport_size = get_viewport_rect().size
	y_distance_between_platforms = 100
	generated_platform_count = 0
	platform_height = 63
	platform_width = 136
	platform_count = 50
	start_platform_y = viewport_size.y - (y_distance_between_platforms*2)

func start_generating_levels():
	generate_level(start_platform_y, true)

func _process(_delta):
	# if the player object is created
	if player:
		# determine the current player position
		var player_y = player.global_position.y
		# figure out where the end of the y position of generated platforms should be
		var end_of_level_position = start_platform_y - (generated_platform_count * y_distance_between_platforms)
		# setup a threshold for where to add more platforms
		var threshold = end_of_level_position + (y_distance_between_platforms*6)
		# if the player is above the threshold...
		if player_y <= threshold:
			# generate more platforms based on the new y starting position
			generate_level(end_of_level_position, false)

func generate_level(start_y: float, generate_ground: bool):
	if generate_ground == true:
		# loop as many times as the platform height fits into the viewport width
		for i in ceil(viewport_size.x/platform_width):
			create_platform(Vector2(i * platform_width,viewport_size.y - platform_height))
	# set the distance between platforms
	# loop through the platform_count to generate that number of platforms
	for i in range(platform_count):
		# set a random x position for the platform between 0 and the viewport width minus the platform width
		var target_position: Vector2 = Vector2( 0 , 0 )
		target_position.x = randf_range(0,viewport_size.x-platform_width)
		# set the y position equal to the target y position minus the distance between platforms times the loop number
		target_position.y = start_y - (y_distance_between_platforms * i)
		create_platform( target_position )
		generated_platform_count += 1
#		print(generated_platform_count)

func create_platform(location: Vector2):
	var platform = platform_scene.instantiate()
	platform.global_position = location	
	platform_parent.add_child(platform)
	return platform

func reset_level():
	generated_platform_count = 0
	for platform in platform_parent.get_children():
		platform.queue_free()
		
