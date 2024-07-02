extends Node
# in order to make this script available everywhere I go into Project Settings
# the AutoLoad tab, then select the script and give it a nickname
# and add it. Then you can reference the nickname anywhere in the code like a singleton.

func debug_log(message:String):
	# To find the ConsoleLog I needed to select it in the outliner
	# and go to Node in the inspector, then Groups and add it to a group to search below
	var console = get_tree().get_first_node_in_group("debug_console")
	if console:
		var log_label = console.find_child("LogLabel")
		if log_label:
			if !log_label.text.is_empty():
				log_label.text += "\n"
			log_label.text += message
