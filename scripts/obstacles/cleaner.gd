extends Area2D

@export var patrol_distance: float = 80.0
@export var patrol_speed: float = 55.0
@export var attack_trigger_distance: float = 95.0

var start_x: float = 0.0
var direction: int = -1
var is_attacking: bool = false

@onready var anim = $AnimatedSprite2D

func _ready():
	start_x = global_position.x
	body_entered.connect(_on_body_entered)
	anim.play("sweep")

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_parent().get_node_or_null("Player")
		
	if player:
		var dist_x = player.global_position.x - global_position.x
		var abs_dist_x = abs(dist_x)
		
		# Quando o player se aproxima, ela vira para o lado dele e faz a animação de bater com a vassoura
		if abs_dist_x <= attack_trigger_distance:
			is_attacking = true
			anim.flip_h = (dist_x > 0) # Sprite original olha para a esquerda (dist_x < 0)
			if anim.animation != "attack":
				anim.play("attack")
			return
		else:
			is_attacking = false

	# Patrulha varrendo para lá e para cá
	if anim.animation != "sweep":
		anim.play("sweep")
		
	global_position.x += direction * patrol_speed * delta
	if global_position.x <= start_x - patrol_distance:
		direction = 1
	elif global_position.x >= start_x + patrol_distance:
		direction = -1
		
	# Na arte original ela olha para a esquerda (direction == -1 -> flip_h = false)
	anim.flip_h = (direction > 0)

func _on_body_entered(body):
	if body.has_method("take_damage"):
		anim.play("attack")
		body.take_damage("hurt")
