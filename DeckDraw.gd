extends TextureButton
var playerCount = 0
var CardsDrawn = 0
const MaxHandSize = 320

func _gui_input(_event):
	if Input.is_action_just_released("leftclick") && !disabled:
		CardsDrawn += 1
		$'../../'.drawCard()
		playerCount = $'../../'/Cards.get_child_count()
		if playerCount >= MaxHandSize:
			disabled = true


func _on_mouse_entered():
	playerCount = $'../../'/Cards.get_child_count()
	if playerCount < MaxHandSize:
		disabled = false
