extends Control

# ==========================================================
# MANUAL "COMO JOGAR"
# Tela aberta pelo menu principal. Todo o texto fica aqui em
# cima para ser fácil de editar. As imagens dos obstáculos são
# lidas das próprias cenas, então se a arte mudar o manual
# acompanha automaticamente.
# ==========================================================

signal closed

const OBJETIVO_TEXTO = "Você é um discente que, sem querer, derramou café no servidor do laboratório. O curto-circuito está se espalhando e, em 60 segundos, o lab vai ser totalmente danificado!\n\nSeu relatório de pesquisa ficou aberto no seu PC, lá no fim do laboratório... e você esqueceu de salvar!\n\n➜ Corra até o seu PC, desviando dos obstáculos.\n➜ Quando chegar, clique em SALVAR antes que o tempo acabe.\n➜ Você tem 3 vidas. Cada batida custa 1 vida e alguns segundos caído no chão.\n➜ Atenção: na janela de salvar o tempo CONTINUA correndo, e \"Não Salvar\" faz você perder o relatório!"

# [tecla, ação]
const CONTROLES = [
	["ESPAÇO  ou  SETA ↑", "Pular"],
	["SETA ↓ (segurar)", "Deslizar (passa por baixo dos fios)"],
	["P  ou  botão ⏸", "Pausar o jogo"],
	["M  ou  botão 🔊", "Ligar / desligar o som"],
	["MOUSE", "Clicar em SALVAR no fim da fase"],
	["ESPAÇO  ou  ENTER", "Pular a introdução"],
]
const CONTROLES_DICA = "O personagem corre sozinho para a direita: você só precisa pular e deslizar na hora certa!"

# [cena, nome, descrição, (opcional) ícone]
const OBSTACULOS = [
	["res://scenes/obstacles/a4_papers.tscn", "Papéis A4", "Escorregadios! Pule por cima."],
	["res://scenes/obstacles/pencils.tscn", "Lápis", "Rolam no chão e fazem escorregar. Pule!"],
	["res://scenes/obstacles/tangled_wires.tscn", "Fios embolados", "Fazem você tropeçar. Pule!"],
	["res://scenes/obstacles/obstacle_notebook.tscn", "Notebook no chão", "Tropeço garantido. Pule!"],
	["res://scenes/obstacles/water_cooler.tscn", "Bebedouro", "Cuidado com a poça d'água: pule ela!"],
	["res://scenes/obstacles/cleaner.tscn", "Faxineira", "Dá vassouradas em quem chega perto. Pule por cima!"],
	["res://scenes/environment/air_conditioner.tscn", "Ar-condicionado", "O vento deixa você mais lento enquanto estiver embaixo dele."],
	["res://scenes/obstacles/hanging_wire.tscn", "Fio desencapado", "Solta faíscas na altura da cabeça. Não dá para pular: DESLIZE por baixo!", "res://art/obstacles/hanging_wire_icon.png"],
]

# [cena, nome, descrição]
const ITENS = [
	["res://scenes/environment/collectible_time.tscn", "Display Points", "+5 segundos no cronômetro e +10 pontos. Pegue todos que puder!"],
	["res://scenes/environment/notebook.tscn", "Seu PC", "A chegada! Ao encostar, clique em SALVAR para vencer (+200 pontos)."],
]

const COR_FUNDO = Color(0.12549, 0.164706, 0.282353, 1) # mesma cor sólida do menu
const COR_TITULO = Color(1, 0.8, 0.2)
const COR_TEXTO = Color(0.92, 0.92, 0.95)
const COR_DESTAQUE = Color(1, 0.85, 0.35)

var tabs: TabContainer
var back_button: Button

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var bg = ColorRect.new()
	bg.color = COR_FUNDO
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	var title = _label("COMO JOGAR", 22, COR_TITULO)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 5)
	vbox.add_child(title)

	tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.add_theme_font_size_override("font_size", 13)
	tabs.focus_mode = Control.FOCUS_NONE
	vbox.add_child(tabs)

	_add_tab("OBJETIVO", _build_objetivo())
	_add_tab("CONTROLES", _build_controles())
	_add_tab("OBSTÁCULOS", _build_lista(OBSTACULOS, "Bater em um obstáculo tira 1 vida e te deixa alguns segundos no chão."))
	_add_tab("ITENS", _build_lista(ITENS, ""))

	var bottom = HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.add_theme_constant_override("separation", 14)
	vbox.add_child(bottom)

	var hint = _label("◀ ▶ trocar aba", 11, Color(0.7, 0.7, 0.75))
	bottom.add_child(hint)

	back_button = Button.new()
	back_button.text = "VOLTAR"
	back_button.custom_minimum_size = Vector2(120, 30)
	back_button.add_theme_font_size_override("font_size", 16)
	back_button.pressed.connect(_close)
	bottom.add_child(back_button)

	var hint2 = _label("ESC voltar", 11, Color(0.7, 0.7, 0.75))
	bottom.add_child(hint2)

	back_button.grab_focus()

func _input(event):
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_ESCAPE:
				_close()
				get_viewport().set_input_as_handled()
			KEY_RIGHT:
				tabs.current_tab = (tabs.current_tab + 1) % tabs.get_tab_count()
				get_viewport().set_input_as_handled()
			KEY_LEFT:
				tabs.current_tab = (tabs.current_tab - 1 + tabs.get_tab_count()) % tabs.get_tab_count()
				get_viewport().set_input_as_handled()

func _close():
	closed.emit()
	queue_free()

# ---------------- Abas ----------------

func _add_tab(title: String, content: Control):
	var page = MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		page.add_theme_constant_override("margin_" + side, 10)
	page.add_child(content)
	tabs.add_child(page)
	tabs.set_tab_title(tabs.get_tab_count() - 1, title)

func _build_objetivo() -> Control:
	var label = _label(OBJETIVO_TEXTO, 12, COR_TEXTO)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _build_controles() -> Control:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)

	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 6)
	for c in CONTROLES:
		grid.add_child(_key_chip(c[0]))
		grid.add_child(_label(c[1], 13, COR_TEXTO))
	vbox.add_child(grid)

	var dica = _label("💡 " + CONTROLES_DICA, 12, COR_DESTAQUE)
	dica.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(dica)
	return vbox

func _build_lista(items: Array, rodape: String) -> Control:
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 6)

	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 4)
	vbox.add_child(grid)

	for item in items:
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 8)

		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(44, 34)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		# Item pode ter um ícone próprio (4º valor); senão usa a imagem da cena
		icon.texture = load(item[3]) if item.size() > 3 else _texture_from_scene(item[0])
		row.add_child(icon)

		var text_box = VBoxContainer.new()
		text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_box.add_theme_constant_override("separation", 0)
		text_box.add_child(_label(item[1], 13, COR_DESTAQUE))
		var desc = _label(item[2], 11, COR_TEXTO)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.custom_minimum_size.x = 180
		text_box.add_child(desc)
		row.add_child(text_box)

		grid.add_child(row)

	if rodape != "":
		var r = _label("⚠ " + rodape, 12, Color(1, 0.45, 0.45))
		r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(r)
	return vbox

# ---------------- Utilitários ----------------

func _label(text: String, font_size: int, color: Color) -> Label:
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l

func _key_chip(text: String) -> Label:
	var l = _label(text, 12, Color(0.1, 0.1, 0.12))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.9, 0.9, 0.92)
	sb.border_color = Color(0.55, 0.55, 0.6)
	sb.set_border_width_all(1)
	sb.border_width_bottom = 3
	sb.set_corner_radius_all(4)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	l.add_theme_stylebox_override("normal", sb)
	return l

# Pega a primeira imagem (Sprite2D ou AnimatedSprite2D) de uma cena
func _texture_from_scene(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	var packed = load(path)
	if packed == null:
		return null
	var inst = packed.instantiate()
	var tex = _find_texture(inst)
	inst.free()
	return tex

func _find_texture(node: Node) -> Texture2D:
	if node is Sprite2D and node.texture:
		return node.texture
	if node is AnimatedSprite2D and node.sprite_frames:
		var anim_name = node.animation
		if not node.sprite_frames.has_animation(anim_name):
			var names = node.sprite_frames.get_animation_names()
			if names.is_empty():
				return null
			anim_name = names[0]
		if node.sprite_frames.get_frame_count(anim_name) > 0:
			return node.sprite_frames.get_frame_texture(anim_name, 0)
	for child in node.get_children():
		var t = _find_texture(child)
		if t:
			return t
	return null
