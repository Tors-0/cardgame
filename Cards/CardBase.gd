extends MarginContainer


@onready var OverlayDatabase = load("res://Assets/Cards/OverlaysDatabase.gd")
var Cardname = 'Zero'
@onready var CardInfo = OverlayDatabase.DATA[OverlayDatabase.get(Cardname)]
@onready var OverlayImg = str("res://Assets/Cards/overlay/", CardInfo[2], ".png")

var Colorname = 'Wenge'
@onready var CardDatabase = load("res://Assets/Cards/CardsDatabase.gd")
@onready var CardType = CardDatabase.DATA[CardDatabase.get(Colorname)]
@onready var CardImg = str("res://Assets/Cards/cardback/", CardType[1], ".png")

# States
enum STATES { InHand, InPlay, InMouse, FocusInHand, MoveDrawnCardToHand, ReorganizeHand }
var startpos = Vector2()
var targetpos = Vector2()
var startrot = 0
var targetrot = 0
var origscale = scale.x
var t = 0
var DRAWTIME = 1
var ORGANIZETIME = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	$Overlay.texture = load(OverlayImg)
	$Card.texture = load(CardImg)
	$CardBack.texture = load("res://Assets/Cards/deck-cover.png")
	var CardName = str("  ", CardType[0], "  \n  ", CardInfo[1], "  ")
	if (CardInfo[4]):
		CardName = str("  ", CardInfo[1], "  ")
	$CardExtras/MarginContainer/HBoxContainer/MarginContainer/CenterContainer/Name.text = CardName
	$CardExtras.hide()
	$CardBack.show()

func _input(_event):
	if (Input.is_action_just_released("rightclick")):
		$CardExtras.visible = !$CardExtras.visible
	if (Input.is_action_just_released("leftclick")):
		$CardExtras.visible = false

var state = STATES.InHand
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	match state:
		STATES.InHand:
			pass
		STATES.InPlay:
			pass
		STATES.InMouse:
			pass
		STATES.FocusInHand:
			pass
		STATES.MoveDrawnCardToHand: # animation from deck to hand
			if t <= DRAWTIME:
				position = startpos.lerp(targetpos, t)
				rotation = startrot * (DRAWTIME - t) + targetrot * t
				scale.x = origscale * abs(2*t - 1)
				if $CardBack.visible:
					if t >= float(DRAWTIME) / 2:
						$CardBack.visible = false
				t += delta / float(DRAWTIME)
			else:
				position = targetpos
				rotation = targetrot
				state = STATES.InHand
				t = 0
		STATES.ReorganizeHand:
			if t <= DRAWTIME:
				position = startpos.lerp(targetpos, t)
				rotation = startrot * (1 - t) + targetrot * t
				t += delta / float(ORGANIZETIME)
			else:
				position = targetpos
				rotation = targetrot
				state = STATES.InHand
				t = 0
