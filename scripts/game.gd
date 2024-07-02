extends Node2D

signal pause_game
signal player_died(score, highscore)

@onready var parallax_bg:ParallaxBackground = $ParallaxBackground
@onready var level_generator = $LevelGenerator
@onready var ground_sprite = $GroundSprite
@onready var hud = $UILayer/HUD

var player_start_position:Vector2
var viewport_size:Vector2
var camera_scene = preload("res://scenes/game_camera.tscn")
var player_scene = preload("res://scenes/player.tscn")
var camera: Camera2D = null
var player: Player = null
var score:int = 0

var save_file_path = "user://highscore.save"
var highscore:int = 0

var new_skin_unlocked = true

# Called when the node enters the scene tree for the first time.
func _ready():
	hud.pause_game.connect(_on_hud_pause_game)
	load_score()
	# alter the UI for startup
	hud.visible = false
	ground_sprite.visible = false
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
	# new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	if player:
		if score < viewport_size.y - player.global_position.y:
			score = viewport_size.y - player.global_position.y
			hud.set_score(score)
		
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
	# always reset the game before starting a new one
	reset_game()
	score = 0
	# add the new player for the new game dynamically
	player = player_scene.instantiate()
	player.global_position = player_start_position
	add_child(player)
	if new_skin_unlocked:
		player.use_new_skin()
	player.connect("died",_on_player_died)
	# add a game_camera to the game and instantiate it
	camera = camera_scene.instantiate()
	# run the custom func setup_camera and pass a reference to the game scene Player instance
	camera.setup_camera(player)
	# add the camera as a child to this game scene
	add_child(camera)
	
	# setup the level generator
	if player:
		level_generator.setup(player)
		level_generator.start_generating_levels()
	# turn the HUD on for a new game
	hud.set_score(0)
	hud.visible = true
	ground_sprite.visible = true

func _on_player_died():
	hud.visible = false
	if score > highscore:
		highscore = score
		save_score()
	player_died.emit(score,highscore)
	
func reset_game():
	# hide the ground on reset
	ground_sprite.visible = false
	# remove all of the level platforms that exist
	level_generator.reset_level()
	hud.set_score(0)
	hud.visible = false
	# if there is a player, then remove it and a reference to it from the level generator
	if player != null:
		player.queue_free()
		player = null
		level_generator.player = null
	
	#if there is a camera, remove the camera
	if camera != null:
		camera.queue_free()
		camera = null
	
func save_score():
	# the first time you call this, it creates the file and saves it
	var score_board = FileAccess.open(save_file_path,FileAccess.WRITE)
	# variables are stored in the order they are created
	score_board.store_var(highscore)
	score_board.close()
		
func load_score():
	# we need to check and see if the file is there
	if FileAccess.file_exists(save_file_path):
		var score_board = FileAccess.open(save_file_path,FileAccess.READ)
		# because vars are stored in order, it returns highscore as the first saved var
		highscore = score_board.get_var()
		score_board.close()
	else:
		highscore = 0

func _on_hud_pause_game():
	pause_game.emit()
