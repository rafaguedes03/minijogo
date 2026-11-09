extends CanvasLayer

var time_left: float = 60.0
var points: int = 0
var lives: int = 3
var game_ended: bool = false
var is_paused: bool = false
var is_save_dialog_open: bool = false

@onready var time_label = $MarginContainer/HBoxContainer/TimeLabel
@onready var points_label = $MarginContainer/HBoxContainer/PointsLabel
@onready var end_screen = $EndScreen
@onready var title_label = $EndScreen/VBoxContainer/TitleLabel

@onready var pause_screen = $PauseScreen
@onready var continue_button = $PauseScreen/VBoxContainer/ContinueButton
@onready var restart_button = $PauseScreen/VBoxContainer/RestartButton
@onready var quit_button = $PauseScreen/VBoxContainer/QuitButton

# Janela estilo Windows de Salvar Arquivo
@onready var windows_save_dialog = $WindowsSaveDialog
@onready var btn_salvar = $WindowsSaveDialog/WindowPanel/VBox/ButtonRow/BtnSalvar
@onready var btn_nao_salvar = $WindowsSaveDialog/WindowPanel/VBox/ButtonRow/BtnNaoSalvar
@onready var btn_cancelar = $WindowsSaveDialog/WindowPanel/VBox/ButtonRow/BtnCancelar
@onready var btn_close_x = $WindowsSaveDialog/WindowPanel/TitleBar/CloseButton
@onready var warning_label = $WindowsSaveDialog/WindowPanel/VBox/WarningLabel

@onready var hbox = $MarginContainer/HBoxContainer

# Música da corrida e botões de som / pause
const RUN_MUSIC = preload("res://audio/music/musica-corrida.mp3")
var music_player: AudioStreamPlayer
var mute_button: Button
var pause_button: Button

func _ready():
	add_to_group("hud")
	var lives_label = Label.new()
	lives_label.name = "LivesLabel"
	lives_label.add_theme_font_size_override("font_size", 24)
	lives_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	lives_label.add_theme_color_override("font_outline_color", Color.BLACK)
	lives_label.add_theme_constant_override("outline_size", 4)
	hbox.add_child(lives_label)
	hbox.move_child(lives_label, 0)
	
	_setup_music()
	_setup_top_buttons()
	
	continue_button.pressed.connect(_on_continue_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Conexões dos botões da janela de salvar estilo Windows
	btn_salvar.pressed.connect(_on_salvar_pressed)
	btn_nao_salvar.pressed.connect(_on_nao_salvar_pressed)
	btn_cancelar.pressed.connect(_on_cancelar_pressed)
	btn_close_x.pressed.connect(_on_cancelar_pressed)
	
	update_labels()
	end_screen.hide()
	pause_screen.hide()
	windows_save_dialog.hide()

func _input(event):
	if game_ended:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_P or event.keycode == KEY_P:
			toggle_pause()
		elif event.physical_keycode == KEY_M or event.keycode == KEY_M:
			toggle_mute()

func toggle_pause():
	if game_ended:
		return
	is_paused = not is_paused
	get_tree().paused = is_paused
	if is_paused:
		pause_screen.show()
		continue_button.grab_focus()
	else:
		pause_screen.hide()

func _on_continue_pressed():
	if is_paused:
		toggle_pause()

func _on_restart_pressed():
	is_paused = false
	restart_game()

func _on_quit_pressed():
	is_paused = false
	get_tree().paused = false
	get_tree().quit()

func _process(delta):
	if game_ended:
		if Input.is_physical_key_pressed(KEY_SPACE):
			restart_game()
		return

	if is_paused or get_tree().paused:
		return

	# O cronômetro NÃO para quando a janela de salvar abre!
	if time_left > 0:
		time_left -= delta
		update_labels()
		if is_save_dialog_open:
			warning_label.text = "CORRA! Restam apenas " + str(int(time_left)) + " segundos para salvar!"
		if time_left <= 0:
			if is_save_dialog_open:
				windows_save_dialog.hide()
			show_game_over("Tempo Esgotado!\nO laboratório foi danificado e o relatório se perdeu!")

func show_windows_save_dialog():
	if game_ended: return
	is_save_dialog_open = true
	windows_save_dialog.show()
	btn_salvar.grab_focus()
	# O cronômetro continua correndo em tempo real!

func _on_salvar_pressed():
	if not is_save_dialog_open or game_ended: return
	is_save_dialog_open = false
	windows_save_dialog.hide()
	add_points(200) # Bônus especial de salvar com sucesso!
	show_victory()

func _on_nao_salvar_pressed():
	if not is_save_dialog_open or game_ended: return
	is_save_dialog_open = false
	windows_save_dialog.hide()
	show_game_over("Você clicou em 'Não Salvar'!\nSeu relatório de pesquisa foi perdido!")

func _on_cancelar_pressed():
	if not is_save_dialog_open or game_ended: return
	warning_label.text = "ERRO: Cancelar não é uma opção! O tempo está acabando!"
	warning_label.add_theme_color_override("font_color", Color(1.0, 0.1, 0.1))
	
	# Efeito de tremor na janela
	var panel = $WindowsSaveDialog/WindowPanel
	var orig_x = panel.position.x
	var tween = create_tween()
	tween.tween_property(panel, "position:x", orig_x + 8.0, 0.05)
	tween.tween_property(panel, "position:x", orig_x - 8.0, 0.05)
	tween.tween_property(panel, "position:x", orig_x + 5.0, 0.05)
	tween.tween_property(panel, "position:x", orig_x, 0.05)

func update_labels():
	time_label.text = "TEMPO: " + str(int(time_left))
	points_label.text = "PONTOS: " + str(points)
	
	var lives_label = hbox.get_node_or_null("LivesLabel")
	if lives_label:
		lives_label.text = "VIDAS: " + str(lives) + " ❤ "

func add_time(amount: float):
	time_left += amount
	update_labels()

func add_points(amount: int):
	points += amount
	update_labels()
	if has_node("CollectSound"):
		$CollectSound.play()

func take_damage():
	lives -= 1
	update_labels()
	if lives <= 0:
		show_game_over("Ficou sem vidas!")
		return true
	return false

func show_game_over(reason: String = "Você bateu!"):
	if game_ended: return
	game_ended = true
	is_paused = false
	is_save_dialog_open = false
	if has_node("WindowsSaveDialog"):
		$WindowsSaveDialog.hide()
	pause_screen.hide()
	title_label.text = "FIM DE JOGO!\n" + reason
	title_label.modulate = Color(1.0, 0.2, 0.2)
	end_screen.show()
	get_tree().paused = true

func show_victory():
	if game_ended: return
	game_ended = true
	is_paused = false
	is_save_dialog_open = false
	if has_node("WindowsSaveDialog"):
		$WindowsSaveDialog.hide()
	pause_screen.hide()
	title_label.text = "VITÓRIA!\nRelatório salvo antes do lab apagar!\nPontos: " + str(points)
	title_label.modulate = Color(0.2, 1.0, 0.2)
	end_screen.show()
	get_tree().paused = true

func restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()


# ==========================================
# MÚSICA DA CORRIDA
# ==========================================
func _setup_music():
	music_player = AudioStreamPlayer.new()
	music_player.name = "RunMusic"
	var stream = RUN_MUSIC.duplicate()
	stream.loop = true # Repete a música enquanto o jogo durar
	music_player.stream = stream
	music_player.volume_db = -6.0
	# Pausa junto com o jogo (o HUD roda sempre, mas a música não)
	music_player.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(music_player)
	music_player.play() # O personagem começa a correr assim que a fase carrega

# ==========================================
# BOTÕES DE SOM E PAUSE (canto superior direito)
# ==========================================
func _setup_top_buttons():
	mute_button = _make_top_button()
	mute_button.name = "MuteButton"
	mute_button.tooltip_text = "Ligar/desligar o som (M)"
	mute_button.pressed.connect(toggle_mute)
	hbox.add_child(mute_button)
	
	pause_button = _make_top_button()
	pause_button.name = "PauseButton"
	pause_button.text = "⏸"
	pause_button.tooltip_text = "Pausar (P)"
	pause_button.pressed.connect(toggle_pause)
	hbox.add_child(pause_button)
	
	_update_mute_button()

func _make_top_button() -> Button:
	var b = Button.new()
	b.custom_minimum_size = Vector2(36, 32)
	b.add_theme_font_size_override("font_size", 18)
	# Sem foco: assim o ESPAÇO (pulo) não "aperta" o botão sem querer
	b.focus_mode = Control.FOCUS_NONE
	return b

func toggle_mute():
	# Muta o barramento principal: vale para música e efeitos,
	# e continua mutado mesmo ao reiniciar a fase
	var muted = not AudioServer.is_bus_mute(0)
	AudioServer.set_bus_mute(0, muted)
	_update_mute_button()

func _update_mute_button():
	if mute_button == null: return
	if AudioServer.is_bus_mute(0):
		mute_button.text = "🔇"
	else:
		mute_button.text = "🔊"
