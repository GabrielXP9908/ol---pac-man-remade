extends Control

# ============================================================
#  LeaderboardScene.gd  –  an Root-Node von Leaderboard.tscn
#
#  Benötigte Node-Struktur:
#
#  Control  (diese Datei dranhängen)
#  ├── RegisterPanel      (Control/Panel)
#  │     ├── NameInput    (LineEdit)
#  │     ├── PwInput      (LineEdit, secret=true)
#  │     ├── RegisterBtn  (Button)
#  │     └── ToLoginBtn   (Button)  → wechselt zu LoginPanel
#  └── LoginPanel         (Control/Panel)
#        ├── NameInput    (LineEdit)
#        ├── PwInput      (LineEdit, secret=true)
#        ├── LoginBtn     (Button)
#        └── ToRegisterBtn (Button) → wechselt zu RegisterPanel
# ============================================================

@onready var register_panel   = $RegisterPanel
@onready var reg_name_input   = $RegisterPanel/NameInput
@onready var reg_pw_input     = $RegisterPanel/PwInput
@onready var register_btn     = $RegisterPanel/RegisterBtn
@onready var to_login_btn     = $RegisterPanel/ToLoginBtn

@onready var login_panel      = $LoginPanel
@onready var login_name_input = $LoginPanel/NameInput
@onready var login_pw_input   = $LoginPanel/PwInput
@onready var login_btn        = $LoginPanel/LoginBtn
@onready var to_register_btn  = $LoginPanel/ToRegisterBtn

func _ready() -> void:
	print("[LeaderboardScene] Ready")

	# Signale verbinden
	Leaderboard.player_ready.connect(_on_player_ready)
	Leaderboard.register_failed.connect(_on_register_failed)
	Leaderboard.login_failed.connect(_on_login_failed)
	Leaderboard.highscore_updated.connect(_on_highscore_updated)
	Leaderboard.request_failed.connect(_on_error)

	# Button Signale
	register_btn.pressed.connect(_on_register_pressed)
	login_btn.pressed.connect(_on_login_pressed)
	to_login_btn.pressed.connect(_show_login)
	to_register_btn.pressed.connect(_show_register)

	# Prüfen ob gespeicherter Spieler vorhanden
	if Leaderboard.load_saved_player():
		# Bekannter Spieler – wird verifiziert, warte auf player_ready
		print("[LeaderboardScene] Bekannter Spieler – verifiziere...")
		register_panel.visible = false
		login_panel.visible    = false
	else:
		# Neu → Register Screen zeigen
		_show_register()

# ── Panel-Wechsel ─────────────────────────────────────────────
func _show_register() -> void:
	register_panel.visible = true
	login_panel.visible    = false
	reg_name_input.grab_focus()

func _show_login() -> void:
	register_panel.visible = false
	login_panel.visible    = true
	login_name_input.grab_focus()

# ── Register ─────────────────────────────────────────────────
func _on_register_pressed() -> void:
	var entered_name: String = reg_name_input.text.strip_edges()
	var pw   : String = reg_pw_input.text.strip_edges()
	if entered_name.is_empty() or pw.is_empty():
		print("[LeaderboardScene] Name oder PW leer")
		return
	register_panel.visible = false
	print("[LeaderboardScene] Registriere: %s" % entered_name)
	Leaderboard.register_player(entered_name, pw)

# ── Login ─────────────────────────────────────────────────────
func _on_login_pressed() -> void:
	var entered_name : String = login_name_input.text.strip_edges()
	var pw : String = login_pw_input.text.strip_edges()
	if entered_name.is_empty() or pw.is_empty():
		return
	login_panel.visible = false
	print("[LeaderboardScene] Login: %s" % entered_name)
	Leaderboard.login_player(entered_name, pw)

# ── Callbacks ─────────────────────────────────────────────────
func _on_player_ready(tag: String, hs: int) -> void:
	print("[LeaderboardScene] Spieler bereit: %s | HS: %d – starte Spiel" % [tag, hs])
	GameManager.highscore = Leaderboard.highscore
	GameStateManager.updategamestate(0)

func _on_register_failed(reason: String) -> void:
	push_error("[LeaderboardScene] Registrierung fehlgeschlagen: " + reason)
	_show_register()   # Zurück zum Register-Screen

func _on_login_failed(reason: String) -> void:
	push_error("[LeaderboardScene] Login fehlgeschlagen: " + reason)
	_show_login()      # Zurück zum Login-Screen

func _on_highscore_updated(new_score: int) -> void:
	print("[LeaderboardScene] Highscore aktualisiert: %d" % new_score)

func _on_error(error: String) -> void:
	push_error("[LeaderboardScene] Fehler: " + error)

# ── Optional: Ausloggen ───────────────────────────────────────
func _on_logout_pressed() -> void:
	Leaderboard.logout()
	reg_name_input.text = ""
	reg_pw_input.text   = ""
	_show_register()
