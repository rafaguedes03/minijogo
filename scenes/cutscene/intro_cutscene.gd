extends Node2D

var has_skipped: bool = false
var shake_intensity: float = 0.0
var alarm_active: bool = false

@onready var camera = $Camera2D
@onready var player_sprite = $PlayerSprite
@onready var desk_sprite = $DeskSprite
@onready var monitor_sprite = $MonitorSprite
@onready var keyboard_sprite = $KeyboardSprite
@onready var mug_sprite = $MugSprite
@onready var smoke_sprite = $SmokeSprite
@onready var siren_sprite = $SirenSprite
@onready var red_alarm_rect = $CanvasLayer/RedAlarmOverlay
@onready var dialogue_panel = $CanvasLayer/DialoguePanel
@onready var dialogue_label = $CanvasLayer/DialoguePanel/Label
@onready var alert_banner = $CanvasLayer/AlertBanner
@onready var alert_sublabel = $CanvasLayer/AlertBanner/VBox/SubLabel
@onready var skip_label = $CanvasLayer/SkipLabel
@onready var fade_rect = $CanvasLayer/FadeRect

# Áudios
@onready var sfx_typing = $Sounds/SFXTyping
@onready var sfx_cup = $Sounds/SFXCup
@onready var sfx_zap = $Sounds/SFXZap
@onready var sfx_explosion = $Sounds/SFXExplosion
@onready var sfx_alarm = $Sounds/SFXAlarm
@onready var sfx_run = $Sounds/SFXRun

# Texturas do Monitor e Caneca
const TEX_SCREEN_WORKING = preload("res://art/cutscene/screen_working.png")
const TEX_SCREEN_GLITCH = preload("res://art/cutscene/screen_glitch.png")
const TEX_SCREEN_ALERT = preload("res://art/cutscene/screen_alert.png")
const TEX_MUG_UP = preload("res://art/cutscene/coffee_mug_up.png")
const TEX_MUG_SPILL = preload("res://art/cutscene/coffee_spill.png")

# Texturas do Player
const TEX_PLAYER_STAND = preload("res://art/player/hero/player_stand.png")
const TEX_PLAYER_TALK = preload("res://art/player/hero/player_talk.png")
const TEX_PLAYER_HURT = preload("res://art/player/hero/player_hurt.png")
const TEX_PLAYER_JUMP = preload("res://art/player/hero/player_jump.png")
const TEX_PLAYER_WALK1 = preload("res://art/player/hero/player_run1.png")
const TEX_PLAYER_WALK2 = preload("res://art/player/hero/player_run4.png")

func _ready():
	smoke_sprite.visible = false
	red_alarm_rect.color.a = 0.0
	alert_banner.visible = false
	dialogue_panel.visible = true
	fade_rect.color.a = 0.0
	
	play_cutscene()

func _input(event):
	if has_skipped:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode in [KEY_SPACE, KEY_ENTER, KEY_ESCAPE]:
			skip_cutscene()
	elif event is InputEventMouseButton and event.pressed:
		skip_cutscene()

func _process(delta):
	# Camera shake suave
	if shake_intensity > 0.0:
		camera.offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		shake_intensity = max(0.0, shake_intensity - delta * 15.0)
	else:
		camera.offset = Vector2.ZERO

	# Piscar da luz vermelha de emergência
	if alarm_active:
		var pulse = (sin(Time.get_ticks_msec() * 0.012) + 1.0) * 0.5
		red_alarm_rect.color.a = pulse * 0.4
		siren_sprite.modulate = Color(1.0, 0.4 + 0.6 * pulse, 0.4 + 0.6 * pulse)

func play_cutscene():
	# --- CENA 1 (Duração ~4.0s): O discente mexendo no servidor do lab, com o café ao lado ---
	player_sprite.texture = TEX_PLAYER_STAND
	monitor_sprite.texture = TEX_SCREEN_WORKING
	mug_sprite.texture = TEX_MUG_UP
	dialogue_label.text = "Relatório de pesquisa quase pronto lá no meu PC...\nVou só dar uma olhada no servidor do lab e tomar um café."
	
	sfx_typing.play()
	await wait_seconds(2.0)
	if has_skipped: return
	
	player_sprite.texture = TEX_PLAYER_TALK
	await wait_seconds(2.0)
	if has_skipped: return
	sfx_typing.stop()

	# --- CENA 2 (Duração ~5.0s): O discente derrama café no servidor ---
	dialogue_label.text = "Eita, bati o braço! O CAFÉ NO SERVIDOR NÃO...!!"
	player_sprite.texture = TEX_PLAYER_JUMP
	player_sprite.position.y -= 12
	
	# Caneca tomba
	mug_sprite.texture = TEX_MUG_SPILL
	mug_sprite.position = Vector2(330, 246)
	sfx_cup.play()
	
	# Tempo para ler o susto da caneca caindo
	await wait_seconds(2.0)
	if has_skipped: return
	
	player_sprite.position.y += 12
	player_sprite.texture = TEX_PLAYER_HURT
	shake_intensity = 3.0
	
	# Curto elétrico e pedido de socorro
	sfx_zap.play()
	monitor_sprite.texture = TEX_SCREEN_GLITCH
	dialogue_label.text = "CURTO-CIRCUITO NO SERVIDOR!!\nAS FAÍSCAS ESTÃO SE ESPALHANDO!!"
	
	# Monitor pisca enquanto o jogador lê a fala
	for i in range(7):
		monitor_sprite.modulate = Color(2.0, 2.0, 0.5)
		await wait_seconds(0.2)
		if has_skipped: return
		monitor_sprite.modulate = Color(1.0, 1.0, 1.0)
		await wait_seconds(0.2)
		if has_skipped: return

	# --- CENA 3 (Duração ~3.5s): A explosão do servidor ---
	shake_intensity = 10.0
	sfx_explosion.play()
	smoke_sprite.visible = true
	smoke_sprite.scale = Vector2(0.5, 0.5)
	
	var tween_smoke = create_tween()
	tween_smoke.tween_property(smoke_sprite, "scale", Vector2(1.5, 1.5), 0.8)
	tween_smoke.parallel().tween_property(smoke_sprite, "modulate:a", 0.0, 1.2)
	
	monitor_sprite.texture = TEX_SCREEN_ALERT
	player_sprite.texture = TEX_PLAYER_HURT
	dialogue_label.text = "KABOOOOM! O SERVIDOR EXPLODIU!!"
	
	# Tempo para ler o susto da explosão
	await wait_seconds(3.4)
	if has_skipped: return

	# --- CENA 4 (Duração ~4.5s): Alarme: o curto-circuito vai danificar o lab em 60 segundos ---
	alarm_active = true
	sfx_alarm.play()
	dialogue_panel.visible = false
	alert_banner.visible = true
	alert_sublabel.text = "O CURTO-CIRCUITO ESTÁ SE ESPALHANDO PELO LABORATÓRIO!\nEM 60 SEGUNDOS O LAB VAI SER TOTALMENTE DANIFICADO!"
	
	player_sprite.texture = TEX_PLAYER_HURT
	shake_intensity = 2.0
	
	# Tempo para ler com calma todo o banner de emergência
	await wait_seconds(4.2)
	if has_skipped: return

	# --- CENA 5 (Duração ~3.5s): O discente lembra do relatório não salvo e sai correndo ---
	alert_banner.visible = false
	dialogue_panel.visible = true
	dialogue_label.text = "MEU RELATÓRIO TÁ ABERTO NO PC E EU NÃO SALVEI!!\nPRECISO CHEGAR LÁ ANTES QUE O LAB APAGUE!!"
	
	# Dá 2 segundos para ler a decisão antes do arranque da corrida
	await wait_seconds(2.0)
	if has_skipped: return
	
	sfx_run.play()
	player_sprite.flip_h = false # Olha para a direita
	
	var start_x = player_sprite.position.x
	var target_x = 690.0
	var run_duration = 1.4
	var elapsed = 0.0
	
	while elapsed < run_duration and not has_skipped:
		elapsed += get_process_delta_time()
		var t = elapsed / run_duration
		player_sprite.position.x = lerp(start_x, target_x, t)
		# Alterna os frames de corrida
		if int(elapsed * 10) % 2 == 0:
			player_sprite.texture = TEX_PLAYER_WALK1
		else:
			player_sprite.texture = TEX_PLAYER_WALK2
		await get_tree().process_frame

	start_game()

func wait_seconds(sec: float):
	if has_skipped:
		return
	await get_tree().create_timer(sec).timeout

func skip_cutscene():
	if has_skipped:
		return
	has_skipped = true
	start_game()

func start_game():
	# Fade suave para a transição
	if sfx_alarm.playing:
		sfx_alarm.stop()
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.3)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
