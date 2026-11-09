extends Area2D

@export_enum("slip", "trip", "hurt") var damage_type: String = "slip"

func _ready():
	# Conecta o sinal body_entered para avisar quando algo entrar nesta área
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Se o corpo que colidiu tem a função "take_damage" (nosso player tem), chama ela com o tipo de animação
	if body.has_method("take_damage"):
		body.take_damage(damage_type)
