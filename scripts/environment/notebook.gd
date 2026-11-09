extends Area2D

var has_triggered: bool = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if has_triggered:
		return
	# Se quem encostou for o jogador, congela o jogador e abre a tela de Salvar do Windows!
	if body.name == "Player":
		has_triggered = true
		if body.has_method("freeze_at_pc"):
			body.freeze_at_pc()
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_windows_save_dialog"):
			hud.show_windows_save_dialog()
