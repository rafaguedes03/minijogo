extends Area2D

# ==========================================================
# FIO DESENCAPADO PENDURADO DO TETO
# Fica na altura da cabeça soltando faíscas do curto-circuito.
# Não dá para pular: o jogador precisa DESLIZAR por baixo (seta ↓).
# ==========================================================

@export var sway_degrees: float = 2.5   # Quanto o fio balança
@export var sway_speed: float = 1.8     # Velocidade do balanço

var _time: float = 0.0
var _phase: float = 0.0

@onready var visual = $Visual
@onready var anim = $Visual/AnimatedSprite2D
@onready var sparks = $Visual/Sparks
@onready var zap_sound = $ZapSound

func _ready():
	body_entered.connect(_on_body_entered)
	_phase = randf() * TAU
	anim.play("spark")
	anim.frame = randi() % anim.sprite_frames.get_frame_count("spark")

func _process(delta):
	# Balanço suave (só o visual; a área de dano fica parada)
	_time += delta
	visual.rotation = deg_to_rad(sway_degrees) * sin(_time * sway_speed + _phase)

func _on_body_entered(body):
	if not body.has_method("take_damage"):
		return
	if body.get("is_hurt"):
		return # Já está machucado/invencível
	zap_sound.play()
	# Rajada de faíscas e flash no fio
	sparks.restart()
	var tween = create_tween()
	tween.tween_property(anim, "modulate", Color(2.0, 2.0, 1.2), 0.05)
	tween.tween_property(anim, "modulate", Color(1, 1, 1), 0.25)
	body.take_damage("hurt")
