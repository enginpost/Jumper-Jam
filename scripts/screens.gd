extends CanvasLayer

@onready var console = $Debug/ConsoleLog

@onready var title_screen = $TitleScreen
@onready var pause_screen = $PauseScreen
@onready var game_over_screen = $GameOverScreen

var current_screen = null

# Called when the node enters the scene tree for the first time.
func _ready():
	console.visible = false
	register_buttons()
	change_screen(title_screen)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_toggle_console_pressed():
	# Toggles the visibility of the debug console we created in the game
	console.visible = !console.visible

func register_buttons():
	# we put the reusable TextureButton that is the SCREEN_BUTTON into a group called "buttons"
	var buttons = get_tree().get_nodes_in_group("buttons")
	# now that we have an array of our UI buttons we check to be sure there is at least one
	if buttons.size() > 0:
		for button in buttons:
			# we added a class_name of ScreenButton to the Screen_button script so we can test it here
			# to be sure the button is the right kind of button
			if button is ScreenButton:
				# now we connect all buttons in the group to the local callback function below
				button.clicked.connect(_on_button_pressed)

func _on_button_pressed(button):
	match button.name:
		"TitlePlay":
			change_screen(pause_screen)
		"PauseRetry":
			change_screen(title_screen)
		"PauseBack":
			change_screen(game_over_screen)
		"PauseClose":
			change_screen(title_screen)
		"GameOverRetry":
			change_screen(title_screen)
		"GameOverBack":
			change_screen(pause_screen)

func change_screen(new_screen):
	if current_screen != null:
		# make the current screen disappear
		var tween_invisible = current_screen.disappear()
		await tween_invisible.finished
		# once you set visible = false the UI stops interacting, which is what we want
		current_screen.visible = false
	current_screen = new_screen
	if current_screen != null:
		var tween_visible = current_screen.appear()
		# after the new screen is done appearing, then enable the buttons again
		# remember that the buttons on invisible screen will remain disabled
		await tween_visible.finished
		get_tree().call_group("buttons", "set_disabled",false)
