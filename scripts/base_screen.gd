extends Control

func _ready():
	visible = false
	modulate.a = 0.0
	# ensure all screen buttons are disabled
	get_tree().call_group("buttons","set_disabled", true)

func appear():
	visible = true
	modulate.a = 0.0
	var animation = get_tree().create_tween()
	animation.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return animation.tween_property(self, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC)

func disappear():
	get_tree().call_group("buttons", "set_disabled",true)
	self.modulate.a = 1.0
	var animation = get_tree().create_tween()
	animation.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return animation.tween_property(self, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_CUBIC)
