extends KinematicBody2D

signal init_card(pos)

var drag_enabled = false
var card_dragging
export var speed = 75
var last_position = Vector2(0,0)
var open_position = Vector2(0,0)
var reveal = false
var flipped = false
var on_top = false
var board_node
var original_parent
var suit
var value

func _ready():
	position = Vector2(0, 0)
	board_node = get_node("/root/Board")
	
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				card_dragging = self
				drag_enabled = true
				last_position = position
				get_parent().remove_child(self)
				board_node.add_child(self)
			else:
				drag_enabled = false
				get_parent().remove_child(self)
				original_parent.add_child(self)
										
#func _input(event):
#	if event is InputEventMouseButton:
#		if event.button_index == BUTTON_LEFT and not event.pressed:
#			drag_enabled = false

			
func _physics_process(delta):
	var movement = Vector2()
	
	if drag_enabled:
		var new_position = get_global_mouse_position()
		movement = new_position - position
		var collision = move_and_collide(movement)
		if collision:
			print("I collided with ", collision.collider.name)
	else:
		if flipped and card_dragging == self:
			print(card_dragging)
			card_dragging = null
			$Tween.interpolate_property(self, "position", position, last_position, 0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			$Tween.start()

	input_pickable = flipped and on_top

func _on_dock_card(body, position):
	print(body)
	print(self)
	if self == body:
		last_position = position

func _on_init_card(pos, card, s, v):
	if(card == self):
		last_position = pos
		suit = s
		value = v
		var textureStr = "assets/Pack/%s_%s.png"
		var texture = textureStr % [suit, value]
		$Front.texture = load(texture)

func _on_reset_card(pos, card):
	if(card == self):
		position = pos

func _on_flip_card(card, pos):
	if(card == self):
		if not flipped:
			$AnimationPlayer.play("Flip")
			flipped = true
		else:
			$AnimationPlayer.play_backwards("Flip")
			flipped = false

func _on_set_parent(card, parent):
	if card == self:
		original_parent = parent
		
func _on_set_last_position(card, pos):
	if card == self:
		last_position = pos

func _on_set_card_on_top(card, is_on_top):
	if card == self:
		on_top = is_on_top
