extends CharacterBody2D

class_name Player

signal died

@onready var animator = $AnimationPlayer
@onready var cshape = $CollisionShape2D
@onready var sprite = $Sprite2D

var viewport_size
var speed = 300.0
var accelerometer_speed = 130
var gravity = 15.0
var max_fall_velocity = 1000.0
var jump_velocity = -800.0
var use_accelerometer:bool
var dead:bool = false

var fall_animation_name = "fall"
var jump_animation_name = "jump"

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_size = get_viewport_rect().size
	use_accelerometer = false
	if OS.get_name() == "Android":
		use_accelerometer = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if velocity.y > 0:
		if animator.current_animation != fall_animation_name:
			animator.play(fall_animation_name)
	elif velocity.y < 0:
		if animator.current_animation != jump_animation_name:
			animator.play(jump_animation_name)

# use the physics process function hook to move the thing attached to the script
func _physics_process(_delta):
	# add gravity to the player
	velocity.y += gravity
	if velocity.y > max_fall_velocity:
		velocity.y = max_fall_velocity
	
	if !dead:
		if use_accelerometer:
			var accelerometer_movement = Input.get_accelerometer()
			velocity.x = accelerometer_movement.x * accelerometer_speed
			#GameUtility.debug_log("tilt x:" + str(velocity.x))
		else:
			# move_left = -1 while move_right = 1
			var direction = Input.get_axis("move_left", "move_right")
			# if we have a valid directional input (any number not zero) then
			if direction:
				# set the horizontal position = spee (300) to the right (1) or the left(-1)
				velocity.x = direction * speed
				
			else:
				# immediately stop the movement
				# if you want the player to gradually stop, then 
				# divide the speed by like a quarter of it's value
				velocity.x = move_toward(velocity.x, 0, speed)
		# go ahead and make the move
	move_and_slide()
	teleport_at_the_edges()

func teleport_at_the_edges():
	var teleport_margin = 20
	# is the player leaving the right side of the screen?
	if global_position.x > viewport_size.x + teleport_margin:
		# teleport to the left side edge minus the teleport_margin
		global_position.x = -teleport_margin
	# is the player leaving the left size of the screen?
	if global_position.x < 0 - teleport_margin:
		# teleport to the right side of the screen plus the teleport_margin
		global_position.x = viewport_size.x + teleport_margin
	# print(viewport_size)

func jump():
	velocity.y = jump_velocity
	SoundFX.play("Jump")


func _on_visible_on_screen_notifier_2d_screen_exited():
	die()

func die():
	if !dead:
		dead = true
		cshape.set_deferred("disabled", true)
		died.emit()
		SoundFX.play("Fall")

func use_new_skin():
	fall_animation_name = "fall_red"
	jump_animation_name = "jump_red"

	if sprite:
		sprite.texture = preload("res://assets/textures/character/Skin2Idle.png")
		
