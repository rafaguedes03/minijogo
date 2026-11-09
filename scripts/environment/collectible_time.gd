extends Area2D

# DISPLAY POINTS: item coletável que dá pontos e segundos extras ao discente

@export var time_bonus: float = 5.0
@export var points_bonus: int = 10

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Checa se o corpo que tocou é o jogador
	if body.name == "Player":
		# Procura o HUD no grupo que nós criamos
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.add_time(time_bonus)
			hud.add_points(points_bonus)
		
		# Remove o Display Point após ser coletado
		queue_free()
