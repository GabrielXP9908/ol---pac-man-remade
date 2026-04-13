extends Control

# ============================================================
#  LeaderboardUI_example.gd  –  an Root-Control von Leaderboard.tscn
#
#  Node-Struktur:
#
#  Control
#  ├── RegisterPanel
#  │     ├── NameInput, PwInput, RegisterBtn, ToLoginBtn
#  ├── LoginPanel
#  │     ├── NameInput, PwInput, LoginBtn, ToRegisterBtn
#  └── LeaderboardPanel          ← NEU
#        ├── TitleLabel
#        ├── HeaderRow (HBoxContainer)
#        │     ├── NrCol, NameCol, LevelCol, ScoreCol (Labels)
#        ├── ScrollContainer
#        │     └── EntriesBox (VBoxContainer)  ← Zeilen werden hier dynamisch eingefügt
#        ├── Separator (HSeparator)
#        ├── PlayerRow (HBoxContainer)
#        │     ├── PlayerNr, PlayerName, PlayerLevel, PlayerScore (Labels)
#        ├── PlayBtn (Button)  "Spielen"
#        └── RefreshTimer (Timer)  wait_time=10, autostart=false
# ============================================================

# ── Register Panel ───────────────────────────────────────────
@onready var register_panel   = $RegisterPanel
@onready var reg_name_input   = $RegisterPanel/NameInput
@onready var reg_pw_input     = $RegisterPanel/PwInput
@onready var register_btn     = $RegisterPanel/RegisterBtn
@onready var to_login_btn     = $RegisterPanel/ToLoginBtn

# ── Login Panel ───────────────────────────────────────────────
@onready var login_panel      = $LoginPanel
@onready var login_name_input = $LoginPanel/NameInput
@onready var login_pw_input   = $LoginPanel/PwInput
@onready var login_btn        = $LoginPanel/LoginBtn
@onready var to_register_btn  = $LoginPanel/ToRegisterBtn

# ── Leaderboard Panel ─────────────────────────────────────────
@onready var leaderboard_panel = $LeaderboardPanel
@onready var entries_box       = $LeaderboardPanel/ScrollContainer/EntriesBox
@onready var player_nr         = $LeaderboardPanel/PlayerRow/PlayerNr
@onready var player_name_label = $LeaderboardPanel/PlayerRow/PlayerName
@onready var player_level_lbl  = $LeaderboardPanel/PlayerRow/PlayerLevel
@onready var player_score_lbl  = $LeaderboardPanel/PlayerRow/PlayerScore
@onready var play_btn          = $LeaderboardPanel/PlayBtn
@onready var refresh_timer     = $LeaderboardPanel/RefreshTimer

# ── Interne Farben ────────────────────────────────────────────
const COLOR_GOLD   := Color(1.0, 0.85, 0.0)   # #1
const COLOR_SILVER := Color(0.75, 0.75, 0.75) # #2
const COLOR_BRONZE := Color(0.8, 0.5, 0.2)    # #3
const COLOR_PLAYER := Color(0.3, 1.0, 0.5)    # Eigener Eintrag
const COLOR_NORMAL := Color(1, 1, 1)

# ============================================================
#  INIT
# ============================================================

func _ready() -> void:
	print("[LeaderboardScene] Ready | from_menu: %s" % str(Leaderboard.opened_from_menu))

	# Signale verbinden
	Leaderboard.player_ready.connect(_on_player_ready)
	Leaderboard.register_failed.connect(_on_register_failed)
	Leaderboard.login_failed.connect(_on_login_failed)
	Leaderboard.highscore_updated.connect(_on_highscore_updated)
	Leaderboard.request_failed.connect(_on_error)
	Leaderboard.leaderboard_loaded.connect(_on_leaderboard_loaded)

	# Buttons verbinden
	register_btn.pressed.connect(_on_register_pressed)
	login_btn.pressed.connect(_on_login_pressed)
	to_login_btn.pressed.connect(_show_login)
	to_register_btn.pressed.connect(_show_register)
	play_btn.pressed.connect(_on_play_pressed)
	refresh_timer.timeout.connect(_on_refresh_timer)

	# Alle Panels ausblenden
	_hide_all()

	if Leaderboard.opened_from_menu:
		# Über Menu-Button → direkt Leaderboard zeigen (bereits eingeloggt)
		_show_leaderboard_panel()
	else:
		# App-Start → verifizieren/registrieren
		if Leaderboard.load_saved_player():
			print("[LeaderboardScene] Bekannter Spieler – verifiziere...")
			# Warte auf player_ready → dann zu Title Screen
		else:
			_show_register()

# ============================================================
#  PANEL HELPER
# ============================================================

func _hide_all() -> void:
	register_panel.visible    = false
	login_panel.visible       = false
	leaderboard_panel.visible = false

func _show_register() -> void:
	_hide_all()
	register_panel.visible = true
	reg_name_input.grab_focus()

func _show_login() -> void:
	_hide_all()
	login_panel.visible = true
	login_name_input.grab_focus()

func _show_leaderboard_panel() -> void:
	_hide_all()
	leaderboard_panel.visible = true
	Leaderboard.fetch_leaderboard()
	refresh_timer.start()

# ============================================================
#  LEADERBOARD ANZEIGE
# ============================================================

func _on_leaderboard_loaded(entries: Array, player_rank: int, player_entry: Dictionary) -> void:
	# Alle alten Einträge löschen
	for child in entries_box.get_children():
		child.queue_free()

	# Einträge aufbauen
	var show_count = min(entries.size(), 17)
	for i in show_count:
		var entry = entries[i]
		var rank   = i + 1
		var is_me  := int(entry.get("owner_id", -1)) == Leaderboard.player_id

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)

		var nr_lbl  := _make_label("#%d" % rank,         80,  is_me or rank <= 3)
		var nm_lbl  := _make_label(str(entry.get("name",  "?")),  200, is_me or rank <= 3)
		var lv_lbl  := _make_label(str(entry.get("level", "?")),  80,  is_me)
		var sc_lbl  := _make_label(str(entry.get("score", "?")),  120, is_me)

		# Farbe setzen
		var color := COLOR_NORMAL
		if is_me:
			color = COLOR_PLAYER
		elif rank == 1:
			color = COLOR_GOLD
		elif rank == 2:
			color = COLOR_SILVER
		elif rank == 3:
			color = COLOR_BRONZE

		nr_lbl.add_theme_color_override("font_color", color)
		nm_lbl.add_theme_color_override("font_color", color)
		lv_lbl.add_theme_color_override("font_color", color)
		sc_lbl.add_theme_color_override("font_color", color)

		row.add_child(nr_lbl)
		row.add_child(nm_lbl)
		row.add_child(lv_lbl)
		row.add_child(sc_lbl)
		entries_box.add_child(row)

	# Wenn mehr Einträge existieren als angezeigt → "..." anzeigen
	if entries.size() > show_count:
		var dots := Label.new()
		dots.text = "   ..."
		dots.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		entries_box.add_child(dots)

	# Eigene Zeile unten updaten
	var rank_text := "#%d" % player_rank if player_rank > 0 else "#?"
	player_nr.text         = rank_text
	player_name_label.text = str(player_entry.get("name",  Leaderboard.player_tag))
	player_level_lbl.text  = str(player_entry.get("level", 1))
	player_score_lbl.text  = str(player_entry.get("score", Leaderboard.highscore))

	player_nr.add_theme_color_override("font_color", COLOR_PLAYER)
	player_name_label.add_theme_color_override("font_color", COLOR_PLAYER)
	player_level_lbl.add_theme_color_override("font_color", COLOR_PLAYER)
	player_score_lbl.add_theme_color_override("font_color", COLOR_PLAYER)

	print("[LeaderboardScene] Leaderboard angezeigt | %d Einträge | Rank: %s" % [entries.size(), rank_text])

func _make_label(text_val: String, min_w: int, bold: bool) -> Label:
	var lbl := Label.new()
	lbl.text = text_val
	lbl.custom_minimum_size.x = min_w
	lbl.clip_text = true
	return lbl

func _on_refresh_timer() -> void:
	print("[LeaderboardScene] Refresh...")
	Leaderboard.fetch_leaderboard()

# ============================================================
#  AUTH CALLBACKS
# ============================================================

func _on_player_ready(tag: String, hs: int) -> void:
	print("[LeaderboardScene] player_ready: %s | HS: %d" % [tag, hs])
	GameManager.highscore = Leaderboard.highscore

	if Leaderboard.opened_from_menu:
		# Über Menu → Leaderboard zeigen
		_show_leaderboard_panel()
	else:
		# App-Start → zu Title Screen
		GameStateManager.updategamestate(0)

func _on_register_pressed() -> void:
	var entered_name: String = reg_name_input.text.strip_edges()
	var pw: String           = reg_pw_input.text.strip_edges()
	if entered_name.is_empty() or pw.is_empty():
		return
	_hide_all()
	print("[LeaderboardScene] Registriere: %s" % entered_name)
	Leaderboard.register_player(entered_name, pw)

func _on_login_pressed() -> void:
	var entered_name: String = login_name_input.text.strip_edges()
	var pw: String           = login_pw_input.text.strip_edges()
	if entered_name.is_empty() or pw.is_empty():
		return
	_hide_all()
	print("[LeaderboardScene] Login: %s" % entered_name)
	Leaderboard.login_player(entered_name, pw)

func _on_register_failed(reason: String) -> void:
	push_error("[LeaderboardScene] Register fehlgeschlagen: " + reason)
	_show_register()

func _on_login_failed(reason: String) -> void:
	push_error("[LeaderboardScene] Login fehlgeschlagen: " + reason)
	_show_login()

func _on_highscore_updated(new_score: int) -> void:
	print("[LeaderboardScene] Highscore aktualisiert: %d" % new_score)

func _on_error(error: String) -> void:
	push_error("[LeaderboardScene] Fehler: " + error)

# ── "Spielen" Button ─────────────────────────────────────────
func _on_play_pressed() -> void:
	Leaderboard.opened_from_menu = false
	refresh_timer.stop()
	GameStateManager.updategamestate(2)

# ── Optional: Ausloggen ───────────────────────────────────────
func _on_logout_pressed() -> void:
	refresh_timer.stop()
	Leaderboard.logout()
	Leaderboard.opened_from_menu = false
	reg_name_input.text = ""
	reg_pw_input.text   = ""
	_show_register()
