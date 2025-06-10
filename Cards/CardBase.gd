
extends MarginContainer

var Overlay = null
var CardInfo
var OverlayImg : String

@onready var CardDatabase = load("res://Assets/Cards/CardsDatabase.gd")
var CardOrdinal : int = -1
var CardType
var CardImg : String

# States and transition vars
enum STATES { InHand, Selected, InMouse, FocusInHand, MoveDrawnCardToHand, ReorganizeHand }
var startpos : Vector2
var targetpos : Vector2
var defaultpos : Vector2
var startrot : float = 0
var targetrot : float = 0
@onready var startscale : Vector2 = scale
var selectedZoom : bool = false
const CardSize : Vector2 = preload("res://Playspace.gd").CardSize
static var ZoomInSize : float = 1.2
@onready var ZoomInPos := Vector2(0, CardSize.y * -0.4)
var setup : bool = false
var origscale : Vector2 = scale

# drawtime vars
var t : float = 0
static var DRAWTIME : float = 0.5
static var ORGANIZETIME : float = 0.2
static var ZOOMINTIME : float = 0.02


func init_textures():
	# gather asset locations
	if Overlay == -1:
		Overlay = Overlays.WEIGHTS[randi_range(0, Overlays.WEIGHTS.size() - 1)]
	CardInfo = Overlays.DATA.get(Overlay)
	OverlayImg = str("res://Assets/Cards/overlay/", CardInfo[2], ".png")
	$Overlay.texture = load(OverlayImg)
	
	if !CardInfo[4]:
		if CardOrdinal == -1:
			CardOrdinal = randi_range(0, CardDatabase.DATA.size() - 1)
		CardType = CardDatabase.DATA[CardOrdinal]
		CardImg = str("res://Assets/Cards/cardback/", CardType[1], ".png")
	else:
		CardOrdinal = 1000
	
	# loading & init values
	if CardOrdinal != 1000:
		$Card.texture = load(CardImg)
	$CardBack.texture = load("res://Assets/Cards/deck-cover.png")
	var CardName : String
	if (CardInfo[4]):
		CardName = str("  ", CardInfo[1], "  ")
	else:
		CardName = str("  ", CardType[0], "  \n  ", CardInfo[1], "  ")
	
	$CardExtras/MarginContainer/HBoxContainer/MarginContainer/CenterContainer/Name.text = CardName
	$CardExtras.hide()
	$CardBack.show()


# Called when the node enters the scene tree for the first time.
func _ready():
	# scale children
	$Focus.scale *= CardSize / $Focus.size
	
	init_textures()

var state := STATES.InHand


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	match state:
		STATES.InHand:
			pass
		STATES.Selected:
			if setup:
				Setup()
			if t <= 1:
				position = startpos.lerp(targetpos + ZoomInPos, t)
				rotation = startrot * (1 - t) + targetrot * t
				if selectedZoom:
					scale = startscale.lerp(origscale * ZoomInSize, t)
				else:
					scale = startscale.lerp(origscale, t)
				t += delta / float(ZOOMINTIME)
			else:
				position = targetpos + ZoomInPos
				rotation = targetrot
				if selectedZoom:
					scale = origscale * ZoomInSize
				else:
					scale = origscale
		STATES.InMouse:
			pass
		STATES.FocusInHand:
			if setup:
				Setup()
			if t <= 1:
				rotation = startrot * (1 - t) + targetrot * t
				scale = startscale.lerp(origscale * ZoomInSize, t)
				t += delta / float(ZOOMINTIME)
			else:
				rotation = targetrot
				scale = origscale * ZoomInSize
		STATES.MoveDrawnCardToHand: # animation from deck to hand
			if setup:
				Setup()
			if t <= 1:
				position = startpos.lerp(targetpos, t)
				rotation = startrot * (1 - t) + targetrot * t
				scale.x = origscale.x * abs(2*t - 1)
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
			if setup:
				Setup()
			if t <= 1:
				position = startpos.lerp(targetpos, t)
				rotation = startrot * (1 - t) + targetrot * t
				scale = startscale.lerp(origscale, t)
				t += delta / float(ORGANIZETIME)
			else:
				position = targetpos
				rotation = targetrot
				scale = origscale
				state = STATES.InHand


func Setup():
	startpos = position
	startrot = rotation
	startscale = scale
	t = 0
	setup = false


func _on_focus_mouse_entered():
	$CardExtras.show()
	match state:
		STATES.InHand, STATES.ReorganizeHand:
			setup = true
			state = STATES.FocusInHand
		STATES.Selected:
			setup = true
			selectedZoom = true


func _on_focus_mouse_exited():
	$CardExtras.hide()
	match state:
		STATES.FocusInHand:
			setup = true
			state = STATES.ReorganizeHand
		STATES.Selected:
			setup = true
			selectedZoom = false


func _on_focus_gui_input(_event):
	if Input.is_action_just_pressed("leftclick"):
		match state:
			STATES.FocusInHand, STATES.InHand, STATES.MoveDrawnCardToHand:
				if $'../../'.countSelectedCards() < 2:
					setup = true
					state = STATES.Selected
			STATES.Selected:
				setup = true
				state = STATES.ReorganizeHand
				selectedZoom = false
		
		$'../../'.updateUI()
