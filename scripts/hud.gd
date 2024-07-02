extends Control

signal pause_game

@onready var topbar = $TopBar
@onready var topbar_bg = $TopBarBG
@onready var score_label = $TopBar/ScoreLabel
var topbar_margin = 10

func _ready():
	var os_name = OS.get_name()
	GameUtility.debug_log("OS: " + os_name)
	if os_name == "Android" || os_name == "iOS":
		var safe_area = DisplayServer.get_display_safe_area()
		var safe_area_top = safe_area.position.y
		
		if os_name == "iOS":
			var screen_scale = DisplayServer.screen_get_scale()
			safe_area_top = (safe_area_top / screen_scale)
			GameUtility.debug_log("Screen scale: " + str(screen_scale))
		
		topbar.position.y += safe_area_top
		topbar_bg.size.y += safe_area_top + topbar_margin
		GameUtility.debug_log("Safe area: " + str(safe_area))
		GameUtility.debug_log("Top bar position: " + str(DisplayServer.window_get_size()))
		GameUtility.debug_log("Safe area top: " + str(safe_area_top))
		GameUtility.debug_log("Top bar position: " + str(topbar.position))

func _on_pause_button_pressed():
	SoundFX.play("Click")
	pause_game.emit()
	# get_tree().paused = !get_tree().paused

func set_score(new_score):
	score_label.text = str(new_score)
