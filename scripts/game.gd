extends Node2D

@onready var parallax_bg:ParallaxBackground = $ParallaxBackground
@onready var level_generator = $LevelGenerator
@onready var ground_sprite = $GroundSprite

var player_start_position:Vector2
var viewport_size:Vector2
var camera_scene = preload("res://scenes/game_camera.tscn")
var player_scene = preload("res://scenes/player.tscn")
var camera: Camera2D = null
var player: Player = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# determine the startup position of a new player for each new game
	viewport_size = get_viewport_rect().size
	player_start_position = Vector2.ZERO
	player_start_position.x = viewport_size.x/2.0 # horizontal middle of the scene
	player_start_position.y = viewport_size.y - 150 # 150 offset puts the player above the ground
	# position the ground
	ground_sprite.global_position.x = viewport_size.x/2.0
	ground_sprite.global_position.y = viewport_size.y
	# scale the parallax background for the viewport
	var parallax_layers = parallax_bg.get_children()
	if parallax_layers.size() > 0:
		for parallax_layer in parallax_layers:
			if parallax_layer is ParallaxLayer:
				setup_parallax_layer(parallax_layer)
	# start a new game
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		
func get_parallax_sprite_scale(parallax_sprite: Sprite2D):
	var parallax_texture = parallax_sprite.get_texture()
	var parallax_texture_width = parallax_texture.get_width()
	var texture_scale = viewport_size.x / parallax_texture_width
	return Vector2( texture_scale, texture_scale)

func setup_parallax_layer( parallax_layer:ParallaxLayer):
	var parallax_sprite = parallax_layer.find_child("Sprite2D")
	if parallax_sprite != null:
		parallax_sprite.scale = get_parallax_sprite_scale(parallax_sprite)
		parallax_layer.motion_mirroring.y = parallax_sprite.scale.y * parallax_sprite.get_texture().get_height()

func new_game():
	# add the new player for the new game dynamically
	player = player_scene.instantiate()
	player.global_position = player_start_position
	add_child(player)
	# add a game_camera to the game and instantiate it
	camera = camera_scene.instantiate()
	# run the custom func setup_camera and pass a reference to the game scene Player instance
	camera.setup_camera(player)
	# add the camera as a child to this game scene
	add_child(camera)
	
	# setup the level generator
	if player:
		level_generator.setup(player)
