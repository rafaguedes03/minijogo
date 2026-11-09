extends CharacterBody2D

const BASE_SPEED = 200.0
var current_speed = 200.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_sliding = false
var slide_exit_time: float = 0.0 # quadro "levantando" ao sair do deslize
var is_hurt = false
var is_frozen = false
var hurt_anim_name = "hurt"
var active_slowdown: float = 1.0

@onready var collision = $CollisionShape2D
# ATENÇÃO: Mudamos a referência para o novo nó que você criou!
@onready var anim = $AnimatedSprite2D 

func _ready():
	# Personagem novo: sprites 128x128 com o dobro de detalhe, mostrados em escala 0.5
	# (os pés ficam na linha 112 da imagem = base da colisão 32x48)
	anim.scale = Vector2(0.5, 0.5)

func _physics_process(delta):
	# Se chegou ao PC final e a tela de salvar está aberta, fica parado no local
	if is_frozen:
		velocity.x = 0
		velocity.y += gravity * delta
		move_and_slide()
		if anim.sprite_frames.has_animation("idle"):
			anim.play("idle")
		return

	# 1. Aplica gravidade
	velocity.y += gravity * delta
	
	if is_hurt:
		move_and_slide()
		return # Sai da função cedo se estiver machucado (não obedece controles)
	
	# 2. Pulo
	if Input.is_physical_key_pressed(KEY_SPACE) or Input.is_physical_key_pressed(KEY_UP):
		if is_on_floor() and not is_sliding:
			velocity.y = JUMP_VELOCITY
			if has_node("JumpSound"):
				$JumpSound.play()

	# 3. Deslize
	if Input.is_physical_key_pressed(KEY_DOWN):
		if is_on_floor() and not is_sliding:
			start_slide()
	else:
		if is_sliding:
			stop_slide()

	# 4. Movimento com a velocidade atual
	velocity.x = current_speed
	move_and_slide()

	# ==========================================
	# 5. GERENCIADOR DE ANIMAÇÕES
	# ==========================================
	if is_hurt:
		if anim.animation != hurt_anim_name:
			anim.play(hurt_anim_name)
	elif is_sliding:
		if anim.animation != "slide": # não reinicia (a animação não repete)
			anim.play("slide")
	elif slide_exit_time > 0.0 and is_on_floor():
		slide_exit_time -= delta
		anim.play("slide_end")
	elif not is_on_floor():
		anim.play("jump")
	else:
		anim.play("run")

func start_slide():
	is_sliding = true
	collision.shape.size.y = 24
	collision.position.y = 12
	# A arte 'player_slide' já é desenhada encostada no chão
	anim.position.y = 0

func stop_slide():
	is_sliding = false
	slide_exit_time = 0.12
	collision.shape.size.y = 48
	collision.position.y = 0
	# Volta a imagem para a altura normal
	anim.position.y = 0

func take_damage(damage_type: String = "hurt"):
	if is_hurt: return # Se já está machucado/invencível, ignora
	
	if is_sliding:
		stop_slide()
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		var died = hud.take_damage()
		if died:
			return # Se morreu de vez, o HUD já deu Game Over
			
	# === INICIA ROTINA DE MACHUCADO / ESCORREGÃO / TROPEÇO ===
	is_hurt = true
	hurt_anim_name = damage_type if anim.sprite_frames.has_animation(damage_type) else "hurt"
	anim.play(hurt_anim_name)
	
	if damage_type == "slip":
		# Escorrega um pouco para frente com os pés para o alto e cai no chão
		velocity.x = 90.0
		velocity.y = -140.0
		anim.position.y = 0 # arte já desenhada no chão
	elif damage_type == "trip":
		# Tropeça para frente e cai de cara no chão
		velocity.x = 60.0
		velocity.y = -90.0
		anim.position.y = 0 # arte já desenhada no chão
	else:
		velocity.x = 0
	
	current_speed = 0 # Para de correr
	
	# Após o impulso inicial do escorregão/tropeço, para no chão
	await get_tree().create_timer(0.25).timeout
	velocity.x = 0
	
	# Faz o boneco piscar em vermelho enquanto está caído
	for i in range(4):
		anim.modulate = Color(1, 0.2, 0.2) # Vermelho
		await get_tree().create_timer(0.14).timeout
		anim.modulate = Color(1, 1, 1) # Branco/Normal
		await get_tree().create_timer(0.14).timeout
	
	# Se levanta e volta a correr
	anim.position.y = 0
	is_hurt = false
	current_speed = BASE_SPEED * active_slowdown
	if active_slowdown < 1.0:
		anim.modulate = Color(0.5, 0.8, 1.0)
	else:
		anim.modulate = Color(1.0, 1.0, 1.0)

func apply_slowdown(multiplier):
	active_slowdown = multiplier
	if not is_hurt:
		current_speed = BASE_SPEED * multiplier
		anim.modulate = Color(0.5, 0.8, 1.0) # Personagem azul/congelado

func remove_slowdown():
	active_slowdown = 1.0
	if not is_hurt:
		current_speed = BASE_SPEED
		anim.modulate = Color(1.0, 1.0, 1.0) # Cor normal

func freeze_at_pc():
	is_frozen = true
	current_speed = 0.0
	velocity.x = 0.0
	if is_sliding:
		stop_slide()
	if anim.sprite_frames.has_animation("idle"):
		anim.play("idle")
