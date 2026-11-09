extends Control

@onready var play_button = $VBoxContainer/PlayButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var how_to_button = $VBoxContainer/HowToButton
@onready var menu_box = $VBoxContainer
@onready var title = $Title

const HowToPlay = preload("res://ui/how_to_play.gd")

func _ready():
	# Dá o foco automático para o botão "JOGAR", permitindo usar teclado/controle
	play_button.grab_focus()
	
	# Conecta os sinais de "clique" dos botões às nossas funções
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	how_to_button.pressed.connect(_on_how_to_pressed)

func _on_play_pressed():
	# Ao apertar Jogar, inicia a animação/cutscene de contexto antes da fase!
	get_tree().change_scene_to_file("res://scenes/cutscene/intro_cutscene.tscn")

func _on_how_to_pressed():
	# Abre o manual "COMO JOGAR" por cima do menu
	menu_box.hide()
	title.hide() # Fundo só com a cor sólida, sem o nome do jogo
	var manual = HowToPlay.new()
	manual.closed.connect(_on_how_to_closed)
	add_child(manual)

func _on_how_to_closed():
	menu_box.show()
	title.show()
	how_to_button.grab_focus()

func _on_quit_pressed():
	# Fecha o jogo
	get_tree().quit()
