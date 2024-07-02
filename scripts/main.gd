extends Node

@onready var game = $Game
@onready var screens = $Screens

var game_in_progress = false


# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_window_event_callback(_on_window_event)
	screens.start_game.connect( _on_screens_start_game )
	screens.clear_level_for_new_game.connect( _on_clear_level_for_new_game )
	game.player_died.connect( _on_game_ended )
	game.pause_game.connect( _on_game_pause_game )

func _on_window_event(event):
	match event:
		DisplayServer.WINDOW_EVENT_FOCUS_IN:
			print("Event: DisplayServer.WINDOW_EVENT_FOCUS_IN")
			GameUtility.debug_log("Event: WINDOW_EVENT_FOCUS_IN")
		DisplayServer.WINDOW_EVENT_FOCUS_OUT:
			print("Event: DisplayServer.WINDOW_EVENT_FOCUS_OUT")
			GameUtility.debug_log("Event: WINDOW_EVENT_FOCUS_OUT")
			if game_in_progress == true && !get_tree().paused:
				_on_game_pause_game()
				print("Pausing the game")
				GameUtility.debug_log("Pausing the game")
		DisplayServer.WINDOW_EVENT_CLOSE_REQUEST:
			get_tree().quit()


func _on_screens_start_game():
	game_in_progress = true
	game.new_game()
	
func _on_clear_level_for_new_game():
	game_in_progress = false
	game.reset_game()

func _on_game_ended(score, highscore):
	game_in_progress = false
	await(get_tree().create_timer(0.75).timeout)
	screens.game_over(score, highscore)

func _on_game_pause_game():
	get_tree().paused = true
	screens.pause_game()
