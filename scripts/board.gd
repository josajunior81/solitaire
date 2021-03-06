extends Node2D

export (PackedScene) var Card

var cards = []
var available_cards = []
var open_cards = []
var board_cards = {}
var cards_docked = {}
var suits = ["clubs", "hearts", "diamond", "spades"]
var zindex = 1
var dock
var is_dragging = false

signal init_card(pos, card, suit, value)
signal reset_card(pos, card, suit, value)
signal dock_card(card, node)
signal flip_card(card, pos)
signal set_card_parent(card, node)
signal set_card_last_position(card, pos, y_padding)
signal set_card_on_top(card, on_top)

func _ready():
	var dock_id = 1
	for suit in suits:
		cards_docked[dock_id] = []
		dock_id = dock_id + 1
		for i in range(13):
			var card = Card.instance()
			connect("init_card", card, "_on_init_card")
			connect("reset_card", card, "_on_init_card")
			connect("dock_card", card, "_on_dock_card")
			connect("flip_card", card, "_on_flip_card")
			connect("set_card_parent", card, "_on_set_parent")
			connect("set_card_last_position", card, "_on_set_last_position")
			connect("set_card_on_top", card, "_on_set_card_on_top")
			emit_signal("init_card", Vector2(0,0), card, suit, (i+1))
			cards.append(card)
				
	randomize()
	cards.shuffle()

	var index = 1
	while index <= 7:
		board_cards[index-1]=[]
		var card_posy = 0
		var node_name = str(index, "_card")
		var node = get_node(node_name)
		for i in index:
			var card = cards.pop_front()
			node.add_child(card)
			card.position = Vector2(0, card_posy)
			card_posy = card_posy + 40
			board_cards[index-1].append(card)
			emit_signal("set_card_parent", card, node)
			emit_signal("set_card_last_position", card, card.global_position, card.position.y)
			if (i+1) == index:
				emit_signal("flip_card", card, Vector2(0,0))
				emit_signal("set_card_on_top", card, true)
		index = index + 1
	
	#print(board_cards)
	
	for c in cards: 
		$Deck.add_child(c)	
		c.z_index = zindex
		c.add_to_group("cards")
		zindex = zindex + 1
		emit_signal("set_card_parent", c, $Deck)
		emit_signal("set_card_last_position", c, c.global_position, 0)
		
	available_cards = cards
		
func _on_docked(body, dock):
	var new_pos = Vector2($Dock.position.x, $Dock.position.y)
	emit_signal("dock_card", body, new_pos)

func _on_next_card():
	if available_cards.size() > 0:
		var card = available_cards.pop_front()		
		
		$Tween.interpolate_property(card, "position", Vector2(0,0), Vector2(156,0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Tween.start()				
		
		emit_signal("flip_card", card, Vector2(0,0))
		emit_signal("set_card_parent", card, $OpenCard)
		emit_signal("set_card_last_position", card, card.global_position, 0)
		emit_signal("set_card_on_top", card, true)
		
		if open_cards.size() > 0:
			emit_signal("set_card_on_top", open_cards[open_cards.size()-1], false)
		
		open_cards.push_back(card)
		
	else:
		open_cards.clear()						
		for child in $OpenCard.get_children():
			if child is KinematicBody2D:
				available_cards.append(child)
				$OpenCard.remove_child(child)	
				$Deck.add_child(child)
				emit_signal("set_card_parent", child, $Deck)
				emit_signal("set_card_last_position", child, child.global_position, 0)
				emit_signal("flip_card", child, Vector2(0,0))

func _on_card_tween_completed(object, key):
	object.position = Vector2(0,0)
	$Deck.remove_child(object)
	$OpenCard.add_child(object)

func add_card_to_dock(dock_id, card):
	dock = dock_id
	
func _on_start_dragging_card():
	dock = 0
	is_dragging = true

func _on_end_dragging_card(card):
	print(dock)
	if is_dragging and dock > 0 and cards_docked[dock].size() == 0:
		if card.value == 1:
			var dock_space = str(dock, "_dock")
			emit_signal("dock_card", card, get_node(dock_space))
			cards_docked[dock].append(card)
			
	is_dragging = false
			
func _on_1_dock_body_shape_entered(body_id, body, body_shape, area_shape):
	add_card_to_dock(1, body)

func _on_2_dock_body_shape_entered(body_id, body, body_shape, area_shape):
	add_card_to_dock(2, body)

func _on_3_dock_body_shape_entered(body_id, body, body_shape, area_shape):
	add_card_to_dock(3, body)

func _on_4_dock_body_shape_entered(body_id, body, body_shape, area_shape):
	add_card_to_dock(4, body)
