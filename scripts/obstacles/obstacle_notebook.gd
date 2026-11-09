extends Area2D

var is_cracked: bool = false
@onready var anim = $AnimatedSprite2D

func _ready():
	body_entered.connect(_on_body_entered)
	anim.play("intact")

func _on_body_entered(body):
	if body.has_method("take_damage"):
		if not is_cracked:
			is_cracked = true
			anim.play("crack")
		body.take_damage("trip")
