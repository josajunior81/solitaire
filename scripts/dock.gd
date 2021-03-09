extends Area2D

export (Array) var cards_docked = []
export (String) var dock_suit setget _set_suit

func _set_suit(value):
	dock_suit = value
