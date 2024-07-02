extends Node

@onready var sound_players = get_children()

var sounds = {
	"Click" : load("res://assets/sound/Click.wav"),
	"Fall" : load("res://assets/sound/Fall.wav"),
	"Jump": load("res://assets/sound/Jump.wav")
}

func play(sound_name):
	var playable_sound = sounds[sound_name]
	for sound_player in sound_players:
		if !sound_player.playing:
			sound_player.stream = playable_sound
			sound_player.play()
			return
	print("too many sounds trying to play at once")
	GameUtility.debug_log("too many sounds trying to play at once")
