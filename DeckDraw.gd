extends TextureButton
var playerCount = 0

func _gui_input(_event):
	if Input.is_action_just_released("leftclick") && !disabled:
		playerCount = $'../../'.drawCard()
		if playerCount >= 13:
			disabled = true
