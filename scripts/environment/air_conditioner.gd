extends Area2D

@export var slowdown_multiplier: float = 0.4 # Reduz a velocidade para 40%

func _ready():
	# Conectando os sinais quando algo entra ou sai da área do vento
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Se quem entrou na área for o Player (ele tem a função apply_slowdown)
	if body.has_method("apply_slowdown"):
		body.apply_slowdown(slowdown_multiplier)

func _on_body_exited(body):
	# Quando o Player sair do vento, volta ao normal
	if body.has_method("remove_slowdown"):
		body.remove_slowdown()
