extends Node2D

const CardSize = Vector2(100, 150)
const CardBase = preload("res://Cards/CardBase.tscn")
const CardStates = preload("res://Cards/CardBase.gd").STATES

@onready var ViewportSize = Vector2(get_viewport().size)
@onready var HandWidth = Vector2(CardSize.x / 2.0, ViewportSize.x - CardSize.x * 1.5)
@onready var HandHeight = ViewportSize.y - CardSize.y * 2

var angle : float = 0
var CardNum : int = 0
var OvalAngleVector : Vector2
var CardSpread : float = 2.5

# player vars
var gold : int = 16
var gold_format : String = "%+05d"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Deck/DeckDraw.scale = CardSize / $Deck/DeckDraw.size
	$InfoUI/Gold/NinePatchRect/GoldLabel.text = gold_format % gold


func drawCard(ordinal : int = -1, overlay : int = -1):
	angle = 0
	var new_card = CardBase.instantiate()
	new_card.CardOrdinal = ordinal
	new_card.Overlay = overlay
	
	new_card.position = $Deck/DeckDraw.position
	new_card.startpos = $Deck/DeckDraw.position
	new_card.targetpos = Vector2(HandWidth.y, HandHeight)
	new_card.defaultpos = new_card.targetpos
	
	new_card.targetrot = 0
	new_card.state = CardStates.MoveDrawnCardToHand
	
	$Cards.add_child(new_card)
	
	organizeHand()
	
	CardSpread = 2.5 / $Cards.get_child_count()
	return $Cards.get_child_count()


func organizeHand():
	CardNum = 0
	for Card in $Cards.get_children(): # organize hand
		angle = 0
		
		Card.targetpos = Vector2(HandWidth.x, HandHeight)
		Card.targetpos.x += (float(CardNum) / ($Cards.get_child_count() - 1)) * (HandWidth.y - HandWidth.x)
		if CardNum == 0:
			Card.targetpos.x = HandWidth.x
		Card.defaultpos = Card.targetpos
		
		Card.startrot = Card.rotation
		Card.targetrot = 0
		
		CardNum += 1
		if Card.state == CardStates.InHand:
			Card.setup = true
			Card.state = CardStates.ReorganizeHand
			Card.startpos = Card.position
		elif Card.state == CardStates.MoveDrawnCardToHand:
			Card.startpos = Card.targetpos - ((Card.targetpos - Card.position) / (Card.DRAWTIME - Card.t))
		else:
			Card.setup = true
	
	$Debug/CardsDrawn.text = str("Cards Drawn: ", $Deck/DeckDraw.CardsDrawn)
	$Debug/CardsHeld.text = str("Cards Held: ", $Cards.get_child_count(), "/", $Deck/DeckDraw.MaxHandSize)


func _on_play_gui_input(_event):
	pass # Replace with function body.


func _on_craft_gui_input(_event):
	pass # Replace with function body.


func _on_kill_gui_input(_event):
	if Input.is_action_just_released("leftclick"):
		for Card in $Cards.get_children():
			match Card.state:
				CardStates.Selected:
					$Cards.remove_child(Card)
					Card.queue_free()
					gold -= 1
				_:
					Card.setup = true
					Card.state = CardStates.ReorganizeHand
		organizeHand()
		$InfoUI/Gold/NinePatchRect/GoldLabel.text = gold_format % gold
