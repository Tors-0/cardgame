class_name Player
extends Node2D

const CardSize = Vector2(100, 150) * 0.8
const CardBase = preload("res://Cards/CardBase.tscn")
const CardStates = preload("res://Cards/CardBase.gd").STATES

@onready var ViewportSize = Vector2(get_viewport().size)
@onready var HandWidth = Vector2(CardSize.x * 0.5, ViewportSize.x - CardSize.x * 1.5)
@onready var HandHeight = ViewportSize.y - CardSize.y * 2.5

var angle : float = 0
var CardNum : int = 0
var OvalAngleVector : Vector2

# player vars
var gold : int = 16
var gold_format : String = " %d"


func hasGold() -> bool:
	return gold > 0


func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_F11):
		if get_window().mode == Window.MODE_FULLSCREEN:
			get_window().mode = Window.MODE_WINDOWED
		else:
			get_window().mode = Window.MODE_FULLSCREEN


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Deck/DeckDraw.scale = CardSize / $Deck/DeckDraw.size
	$Deck/DeckDraw.position = ViewportSize - CardSize * 1.1
	
	$InfoUI/Gold/NinePatchRect/GoldLabel.text = gold_format % gold
	
	updateUI()



func drawCard(ordinal : int = -1, overlay : int = -1) -> void:
	var new_card = CardBase.instantiate()
	new_card.CardOrdinal = ordinal
	new_card.Overlay = overlay
	
	new_card.position = $Deck/DeckDraw.position
	new_card.startpos = $Deck/DeckDraw.position
	new_card.targetpos = Vector2(HandWidth.y, HandHeight)
	new_card.defaultpos = new_card.targetpos
	
	new_card.scale = CardSize / new_card.size
	new_card.origscale = new_card.scale
	
	new_card.targetrot = 0
	new_card.state = CardStates.MoveDrawnCardToHand
	
	$Cards.add_child(new_card)
	
	organizeHand()


func sort_color(card1 : Node, card2 : Node) -> bool:
	if card1.CardOrdinal < card2.CardOrdinal:
		return true
	elif card1.CardOrdinal > card2.CardOrdinal:
		return false
	else:
		return card1.Overlay < card2.Overlay


func sort_number(card1 : Node, card2 : Node) -> bool:
	if card1.Overlay < card2.Overlay:
		return true
	elif card1.Overlay > card2.Overlay:
		return false
	else:
		return card1.CardOrdinal < card2.CardOrdinal


func organizeHand() -> void:
	CardNum = 0
	var Cards : Array[Node] = $Cards.get_children()
	Cards.sort_custom(sort_number)
	for Card in Cards: # organize hand
		angle = 0
		$Cards.move_child(Card, Cards.size() - 1)
		
		Card.targetpos = Vector2(HandWidth.x, HandHeight)
		Card.targetpos.x += (float(CardNum + 1) / (Cards.size() + 1)) * (HandWidth.y - HandWidth.x)
		Card.defaultpos = Card.targetpos
		
		Card.startrot = Card.rotation
		Card.targetrot = 0
		
		CardNum += 1
		if Card.state == CardStates.InHand:
			Card.setup = true
			Card.state = CardStates.ReorganizeHand
			Card.startpos = Card.position
		elif Card.state == CardStates.MoveDrawnCardToHand:
			Card.startpos = Card.targetpos - ((Card.targetpos - Card.position) / (1 - Card.t))
		else:
			Card.setup = true
	
	updateUI()


func countSelectedCards() -> int:
	var count : int = 0
	for Card in $Cards.get_children():
		if Card.state == CardStates.Selected:
			count += 1
	return count


func getSelectedCards() -> Array[Container]:
	var selCards : Array[Container] = []
	for Card in $Cards.get_children():
		if Card.state == CardStates.Selected:
			selCards.append(Card)
	return selCards


func updateUI() -> void:
	var playButton : TextureButton = $ButtonUI/MarginContainer/HBoxContainer/Play
	var killButton : TextureButton = $ButtonUI/MarginContainer/HBoxContainer/Kill
	var craftButton : TextureButton = $ButtonUI/MarginContainer/HBoxContainer/CraftButtons/Craft
	
	match countSelectedCards():
		0:
			playButton.disabled = true
			killButton.disabled = true
			craftButton.disabled = true
			craftButton.show()
		1:
			playButton.disabled = false
			if hasGold():
				killButton.disabled = false
			craftButton.disabled = true
			craftButton.show()
		2:
			playButton.disabled = true
			killButton.disabled = true
			if hasGold():
				craftButton.disabled = false
	
	$InfoUI/Gold/NinePatchRect/GoldLabel.text = gold_format % gold
	$Debug/CardsDrawn.text = str("Cards Drawn: ", $Deck/DeckDraw.CardsDrawn)
	$Debug/CardsHeld.text = str("Cards Held: ", $Cards.get_child_count(), "/", $Deck/DeckDraw.MaxHandSize)


func _on_play_gui_input(_event) -> void:
	pass # Replace with function body.


func _on_kill_gui_input(_event) -> void:
	if Input.is_action_just_released("leftclick") && hasGold():
		for Card in $Cards.get_children():
			match Card.state:
				CardStates.Selected:
					if gold > 0:
						$Cards.remove_child(Card)
						Card.queue_free()
						gold -= 1
					else:
						Card.setup = true
						Card.state = CardStates.ReorganizeHand
				_:
					Card.setup = true
					Card.state = CardStates.ReorganizeHand
		organizeHand()
		updateUI()


func _on_shift_pressed() -> void:
	if hasGold():
		var Cards := getSelectedCards()
		for Card in Cards:
			Card.CardOrdinal += 1
			if Card.CardOrdinal >= CardNames.DATA.size():
				Card.CardOrdinal = 0
			Card._ready()
			Card.get_child(4).hide()
			Card.setup = true
			Card.state = CardStates.ReorganizeHand
		gold -= 1
		updateUI()


func _on_up_pressed() -> void:
	pass # Replace with function body.
