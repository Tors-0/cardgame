extends MarginContainer

@onready var OverlayDatabase = load("res://Assets/Cards/OverlaysDatabase.gd")
var Overlay = null
var CardInfo
var OverlayImg

@onready var CardDatabase = load("res://Assets/Cards/CardsDatabase.gd")
var CardOrdinal = null
var CardType
var CardImg

# States and transition vars
enum STATES { InHand, Selected, InMouse, FocusInHand, MoveDrawnCardToHand, ReorganizeHand }
var startpos = Vector2()
var targetpos = Vector2()
var defaultpos = Vector2()
var startrot = 0
var targetrot = 0
@onready var startscale = scale
@onready var CardSize = preload("res://Playspace.gd").CardSize
var ZoomInSize = 1.2
@onready var ZoomInPos = Vector2(0, CardSize.y * -0.4)
var setup = false
var origscale = scale

# drawtime vars
var t = 0
var DRAWTIME = 1
var ORGANIZETIME = 0.5
var ZOOMINTIME = 0.05


# Called when the node enters the scene tree for the first time.
func _ready():
	# gather asset locations
	if CardOrdinal == null:
		CardOrdinal = randi_range(0, CardDatabase.DATA.size() - 1)
	CardType = CardDatabase.DATA[CardOrdinal]
	CardImg = str("res://Assets/Cards/cardback/", CardType[1], ".png")
	
	if Overlay == null:
		Overlay = OverlayDatabase.WEIGHTS[randi_range(0, OverlayDatabase.WEIGHTS.size() - 1)]
	CardInfo = OverlayDatabase.DATA.get(Overlay)
	OverlayImg = str("res://Assets/Cards/overlay/", CardInfo[2], ".png")
	
	# scale children
	$Focus.scale *= CardSize / $Focus.size
	$Overlay.texture = load(OverlayImg)
	
	# loading & init values
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
		STATES.Selected:
			if setup:
				Setup()
			if t <= DRAWTIME:
				position = startpos.lerp(targetpos + ZoomInPos*2, t)
				rotation = startrot * (1 - t) + targetrot * t
				scale = startscale.lerp(origscale, t)
				t += delta / float(ORGANIZETIME)
			else:
				position = targetpos + ZoomInPos*2
				rotation = targetrot
				scale = origscale
		STATES.InMouse:
			pass
		STATES.FocusInHand:
			if setup:
				Setup()
			if t <= DRAWTIME:
				position = startpos.lerp(targetpos + ZoomInPos, t)
				rotation = startrot * (1 - t) + targetrot * t
				scale = startscale.lerp(origscale * ZoomInSize, t)
				t += delta / float(ZOOMINTIME)
			else:
				position = targetpos + ZoomInPos
				rotation = targetrot
				scale = origscale * ZoomInSize
		STATES.MoveDrawnCardToHand: # animation from deck to hand
			if setup:
				Setup()
			if t <= DRAWTIME:
				position = startpos.lerp(targetpos, t)
				rotation = startrot * (DRAWTIME - t) + targetrot * t
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
			if t <= DRAWTIME:
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
	match state:
		STATES.InHand, STATES.ReorganizeHand:
			setup = true
			state = STATES.FocusInHand


func _on_focus_mouse_exited():
	match state:
		STATES.FocusInHand:
			setup = true
			state = STATES.ReorganizeHand


func _on_focus_gui_input(_event):
	if Input.is_action_just_pressed("leftclick"):
		match state:
			STATES.FocusInHand, STATES.InHand, STATES.MoveDrawnCardToHand:
				setup = true
				state = STATES.Selected
			STATES.Selected:
				setup = true
				state = STATES.ReorganizeHand
