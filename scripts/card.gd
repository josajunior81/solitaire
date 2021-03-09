extends KinematicBody2D

signal init_card(pos)
signal end_dragging(card)
signal start_dragging()

export (int) var speed = 75
export (int) var value = 0
export (String) var suit = ""
export var drag_enabled = false

var card_dragging
var y_pos = 0
var last_position = Vector2(0,0)
var last_z_index = 0
var open_position = Vector2(0,0)
var reveal = false
var flipped = false
var on_top = false
var board_node
var original_parent

func _ready():
	position = Vector2(0, 0)
	board_node = get_node("/root/Board")	
	connect("start_dragging", board_node, "_on_start_dragging_card")
	connect("end_dragging", board_node, "_on_end_dragging_card")
	
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				card_dragging = self
				drag_enabled = true
				get_parent().remove_child(self)
				board_node.add_child(self)
				z_index = 100
				emit_signal("start_dragging")
			else:
				drag_enabled = false
				emit_signal("end_dragging", self)
										
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
			$Tween.interpolate_property(self, "position", position, last_position, 0.05, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			$Tween.start()
			
	input_pickable = flipped and on_top

func _on_dock_card(body, dock):
	if self == body:
		print(dock.position)
		self.global_position = dock.position
		self.last_position = dock.position
		z_index = 1
		card_dragging = null
		drag_enabled = false

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
		
func _on_set_last_position(card, pos, y_padding):
	if card == self:
		last_position = pos
		y_pos = y_padding
		last_z_index = z_index

func _on_set_card_on_top(card, is_on_top):
	if card == self:
		on_top = is_on_top


func _on_card_tween_completed(object, key):
	if object == self:
		card_dragging = null		
		self.position = Vector2(0, y_pos)
		get_parent().remove_child(self)
		original_parent.add_child(self)
		z_index = last_z_index
