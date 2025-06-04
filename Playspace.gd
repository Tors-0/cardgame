extends Node2D

const CardSize = Vector2(100, 150)
const CardBase = preload("res://Cards/CardBase.tscn")
const PlayerHand = preload("res://Cards/PlayerHand.gd")
const CardDatabase = preload("res://Assets/Cards/CardsDatabase.gd")
const OverlayDatabase = preload("res://Assets/Cards/OverlaysDatabase.gd")
const CardStates = preload("res://Cards/CardBase.gd").STATES
const text = "Cards Drawn: "

@onready var ViewportSize = Vector2(get_viewport().size)
@onready var CenterCardOval = ViewportSize * Vector2(0.5, 1.0)
@onready var Hor_rad = ViewportSize.x * 0.45
@onready var Ver_rad = ViewportSize.y * 0.15
var angle = 0
var CardNum
var NumberCardsHand = 0
var OvalAngleVector = Vector2()
var CardSpread = 0.175

# Called when the node enters the scene tree for the first time.
func _ready():
	$Deck/DeckDraw.scale = CardSize / $Deck/DeckDraw.size

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func drawCard():
	angle = PI/2 + CardSpread * (float(NumberCardsHand)/2 - NumberCardsHand)
	var new_card = CardBase.instantiate()
	new_card.Cardname = OverlayDatabase.DATA[randi_range(0,14)][1]
	new_card.Colorname = CardDatabase.VALUES[randi_range(0,31)]
	
	new_card.position = $Deck/DeckDraw.position
	OvalAngleVector = Vector2(Hor_rad * cos(angle), -Ver_rad * sin(angle))
	new_card.startpos = $Deck/DeckDraw.position
	new_card.targetpos = CenterCardOval + OvalAngleVector - (new_card.size / 2)
	new_card.targetrot = (PI / 2 - angle) / 4
	new_card.state = CardStates.MoveDrawnCardToHand
	
	CardNum = 0
	for Card in $Cards.get_children(): # organize hand
		angle = PI/2 + CardSpread * (float(NumberCardsHand)/2 - CardNum)
		OvalAngleVector = Vector2(Hor_rad * cos(angle), -Ver_rad * sin(angle))
		
		Card.targetpos = CenterCardOval + OvalAngleVector - (new_card.size / 2)
		Card.startrot = Card.rotation
		Card.targetrot = (PI/2 - angle) / 4
		
		CardNum += 1
		if Card.state == CardStates.InHand:
			Card.state = CardStates.ReorganizeHand
			Card.startpos = Card.position
		elif Card.state == CardStates.MoveDrawnCardToHand:
			Card.startpos = Card.targetpos - ((Card.targetpos - Card.position) / (Card.DRAWTIME - Card.t))

	
	$Cards.add_child(new_card)
	$CardsLabel.text = str(text, $Cards.get_child_count(), "/13")
	
	angle -= 0.15
	NumberCardsHand += 1
	return $Cards.get_child_count()
