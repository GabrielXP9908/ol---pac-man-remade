extends Node

# ============================================================
#  SupabaseLeaderboard.gd  –  Autoload als "Leaderboard"
# ============================================================

const SUPABASE_URL := "https://bqpgsfxgaeryyjoiesmk.supabase.co"
const SUPABASE_KEY := "sb_publishable_tDvstahZi6c6OJiG0KvaJw_IZ752ukW"
const SAVE_PATH    := "user://leaderboard_player.json"

# ── Signale ──────────────────────────────────────────────────
signal player_ready(tag: String, highscore: int)   # Spieler eingeloggt/registriert + HS von Supabase geladen
signal register_failed(reason: String)              # Name/PW-Problem bei Registrierung
signal login_failed(reason: String)                 # Falsches PW oder Spieler nicht gefunden
signal highscore_updated(new_score: int)
signal request_failed(error: String)

# ── Public State ─────────────────────────────────────────────
var player_id:   int    = -1
var player_tag:  String = ""   # z.B. "Shadow#00"
var player_name: String = ""   # z.B. "Shadow" (ohne Tag)
var password:    String = ""   # für Auth bei jedem Write
var highscore:   int    = 0

# ── Intern ───────────────────────────────────────────────────
var _pending_score: int = -1
var _pending_level: int = 1

# ============================================================
#  AUTOLOAD INIT
# ============================================================

func _ready() -> void:
	print("[Leaderboard] Ready")
	await get_tree().root.ready
	if get_tree().root.has_node("GameManager"):
		GameManager.gameOver.connect(_on_game_over)
		print("[Leaderboard] GameManager.gameOver verbunden ✓")
	else:
		push_error("[Leaderboard] GameManager nicht gefunden!")

# ============================================================
#  PLAYER SETUP
# ============================================================

## Lädt gespeicherten Spieler aus lokalem Save.
## true  → Daten gefunden, ruft automatisch login() auf Supabase auf
##         um PW zu verifizieren und HS zu laden → warte auf player_ready
## false → Kein Save, zeige Register/Login Screen
func load_saved_player() -> bool:
	var data := _load_player_data()
	if data.is_empty() or data.get("id", -1) == -1:
		print("[Leaderboard] Kein lokaler Save gefunden")
		return false
	print("[Leaderboard] Lokaler Save gefunden: %s – verifiziere mit Supabase..." % data.get("tag","?"))
	# Gespeicherte Daten als Fallback setzen
	player_id   = data.get("id", -1)
	player_tag  = data.get("tag", "")
	player_name = data.get("name", "")
	password    = data.get("password", "")
	highscore   = data.get("highscore", 0)
	# Login verifizieren und frischen HS holen
	_verify_and_fetch(player_name, password)
	return true

## Neuen Spieler registrieren
## → Tag wird automatisch als Name#00 / Name#01 etc. vergeben
## → Warte auf player_ready
func register_player(name: String, pw: String) -> void:
	if name.strip_edges().is_empty():
		emit_signal("register_failed", "Name darf nicht leer sein")
		return
	if pw.strip_edges().is_empty():
		emit_signal("register_failed", "Passwort darf nicht leer sein")
		return

	var clean_name := name.strip_edges().left(20)
	var clean_pw   := pw.strip_edges()
	print("[Leaderboard] Registrierung: '%s'" % clean_name)

	# Nächsten freien Tag von Supabase holen
	var http := _make_http()
	http.request_completed.connect(_on_tag_fetched.bind(http, clean_name, clean_pw))
	http.request(
		SUPABASE_URL + "/rest/v1/rpc/next_player_tag",
		_headers_post(),
		HTTPClient.METHOD_POST,
		JSON.stringify({"base_name": clean_name})
	)

## Bestehenden Spieler einloggen
## → Warte auf player_ready oder login_failed
func login_player(name: String, pw: String) -> void:
	if name.strip_edges().is_empty() or pw.strip_edges().is_empty():
		emit_signal("login_failed", "Name und Passwort dürfen nicht leer sein")
		return
	print("[Leaderboard] Login: '%s'" % name.strip_edges())
	_verify_and_fetch(name.strip_edges(), pw.strip_edges())

## Lokal ausloggen → nächster Start zeigt Register/Login Screen
func logout() -> void:
	print("[Leaderboard] Ausgeloggt: %s" % player_tag)
	player_id   = -1
	player_tag  = ""
	player_name = ""
	password    = ""
	highscore   = 0
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("localStorage.removeItem('ol_leaderboard')")
	else:
		DirAccess.remove_absolute(SAVE_PATH)

# ============================================================
#  GAME OVER  –  von GameManager.gameOver
# ============================================================

func _on_game_over(score: int, level: int) -> void:
	print("[Leaderboard] gameOver – Score: %d | Level: %d" % [score, level])

	if player_id == -1:
		print("[Leaderboard] Kein Spieler – Score als pending gemerkt")
		_pending_score = score
		_pending_level = level
		return
	if score < 100:
		print("[Leaderboard] Score %d < 100 – nicht submitted" % score)
		return
	if score <= highscore:
		print("[Leaderboard] %d <= Highscore %d – kein Update" % [score, highscore])
		return

	print("[Leaderboard] Neuer Highscore %d → %d – sende..." % [highscore, score])
	highscore = score
	_save_player_data()
	_authenticated_score_update(score, level)

# ============================================================
#  AUTHENTIFIZIERTER SCORE UPDATE (Name+PW werden mitgeschickt)
# ============================================================

func _authenticated_score_update(score: int, level: int) -> void:
	# Wir nutzen eine RPC-Funktion die PW prüft bevor sie updatet
	var body := JSON.stringify({
		"p_player_id": player_id,
		"p_password":  password,
		"p_score":     score,
		"p_level":     level
	})
	var http := _make_http()
	http.request_completed.connect(_on_score_done.bind(http, score))
	http.request(
		SUPABASE_URL + "/rest/v1/rpc/update_score_authenticated",
		_headers_post(), HTTPClient.METHOD_POST, body
	)

# ============================================================
#  SUPABASE VERIFY + FETCH (Login & Auto-Login)
# ============================================================

func _verify_and_fetch(input_name: String, pw: String) -> void:
	# Suche per tag (eindeutig) ODER per name (alle Treffer, PW gegen jeden prüfen)
	var is_tag := "#" in input_name
	var endpoint: String
	if is_tag:
		endpoint = SUPABASE_URL + "/rest/v1/players?select=id,name,tag,password&tag=eq." + input_name.uri_encode()
	else:
		endpoint = SUPABASE_URL + "/rest/v1/players?select=id,name,tag,password&name=eq." + input_name.uri_encode()
	print("[Leaderboard] Login-Suche per %s: '%s'" % ["Tag" if is_tag else "Name", input_name])
	var http := _make_http()
	http.request_completed.connect(_on_verify_done.bind(http, pw))
	http.request(endpoint, _headers_get(), HTTPClient.METHOD_GET)

func _on_verify_done(_r, code: int, _h, body: PackedByteArray, http: HTTPRequest, pw: String) -> void:
	http.queue_free()
	if code != 200:
		push_error("[Leaderboard] Verify fehlgeschlagen (HTTP %d)" % code)
		emit_signal("login_failed", "Serverfehler (HTTP %d)" % code)
		return

	var data = JSON.parse_string(body.get_string_from_utf8())
	if not data is Array or data.is_empty():
		print("[Leaderboard] Login: Spieler nicht gefunden")
		emit_signal("login_failed", "Spieler nicht gefunden")
		return

	# Bei mehreren Treffern (gleicher Name) → alle prüfen bis PW passt
	var matched_player = null
	for entry in data:
		if entry.get("password", "") == pw:
			matched_player = entry
			break

	if matched_player == null:
		print("[Leaderboard] Login: Passwort passt zu keinem Eintrag (%d Treffer)" % data.size())
		emit_signal("login_failed", "Falsches Passwort")
		return

	# Login OK
	player_id   = int(matched_player["id"])
	player_name = matched_player["name"]
	player_tag  = matched_player["tag"]
	password    = pw
	print("[Leaderboard] Login OK: %s (ID %d)" % [player_tag, player_id])

	_fetch_highscore_from_supabase()

func _fetch_highscore_from_supabase() -> void:
	print("[Leaderboard] Fetche Highscore für owner_id %d..." % player_id)
	var http := _make_http()
	http.request_completed.connect(_on_highscore_fetched.bind(http))
	http.request(
		SUPABASE_URL + "/rest/v1/leaderboard?select=score&owner_id=eq." + str(player_id),
		_headers_get(), HTTPClient.METHOD_GET
	)

func _on_highscore_fetched(_r, code: int, _h, body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	if code == 200:
		var data = JSON.parse_string(body.get_string_from_utf8())
		if data is Array and data.size() > 0:
			var remote := int(data[0].get("score", 0))
			print("[Leaderboard] Supabase HS: %d | Lokal: %d" % [remote, highscore])
			if remote > highscore:
				highscore = remote
		else:
			print("[Leaderboard] Noch kein Leaderboard-Eintrag – HS bleibt 0")
	else:
		push_error("[Leaderboard] HS-Fetch fehlgeschlagen (HTTP %d)" % code)

	_save_player_data()
	print("[Leaderboard] player_ready: %s | HS: %d" % [player_tag, highscore])
	emit_signal("player_ready", player_tag, highscore)

	# Pending Score verarbeiten falls vorhanden
	if _pending_score >= 100:
		_on_game_over(_pending_score, _pending_level)
	_pending_score = -1

# ============================================================
#  REGISTER CALLBACKS
# ============================================================

func _on_tag_fetched(_r, code: int, _h, body: PackedByteArray, http: HTTPRequest, name: String, pw: String) -> void:
	http.queue_free()
	if code != 200:
		push_error("[Leaderboard] Tag-Fetch fehlgeschlagen (HTTP %d)" % code)
		emit_signal("register_failed", "Serverfehler beim Tag-Check (HTTP %d)" % code)
		return

	var result = JSON.parse_string(body.get_string_from_utf8())
	# next_player_tag gibt einen String zurück
	var tag: String = ""
	if result is String:
		tag = result
	elif result is Dictionary:
		tag = str(result)  # Fallback
	tag = tag.strip_edges().trim_prefix("\"").trim_suffix("\"")

	print("[Leaderboard] Freier Tag ermittelt: %s" % tag)

	# Spieler in players-Tabelle anlegen
	var body2 := JSON.stringify({"name": name, "tag": tag, "password": pw})
	var http2  := _make_http()
	var headers := _headers_post()
	headers.append("Prefer: return=representation")
	http2.request_completed.connect(_on_player_created.bind(http2, name, tag, pw))
	http2.request(SUPABASE_URL + "/rest/v1/players", headers, HTTPClient.METHOD_POST, body2)

func _on_player_created(_r, code: int, _h, body: PackedByteArray, http: HTTPRequest, name: String, tag: String, pw: String) -> void:
	http.queue_free()
	if code != 201:
		push_error("[Leaderboard] Spieler-Erstellung fehlgeschlagen (HTTP %d)" % code)
		emit_signal("register_failed", "Registrierung fehlgeschlagen (HTTP %d)" % code)
		return

	var data = JSON.parse_string(body.get_string_from_utf8())
	if not data is Array or data.is_empty():
		emit_signal("register_failed", "Leere Antwort vom Server")
		return

	player_id   = int(data[0]["id"])
	player_name = name
	player_tag  = tag
	password    = pw
	highscore   = 0
	print("[Leaderboard] Spieler erstellt: %s (ID %d) – Leaderboard-Eintrag wird beim ersten Score erstellt" % [player_tag, player_id])

	_save_player_data()
	emit_signal("player_ready", player_tag, highscore)

	if _pending_score >= 100:
		_on_game_over(_pending_score, _pending_level)
	_pending_score = -1

# ============================================================
#  SCORE CALLBACKS
# ============================================================

func _on_score_done(_r, code: int, _h, body: PackedByteArray, http: HTTPRequest, submitted_score: int) -> void:
	http.queue_free()
	if code == 200:
		var result = JSON.parse_string(body.get_string_from_utf8())
		if result == true or (result is Dictionary and result.get("success", false)):
			print("[Leaderboard] Highscore gespeichert: %d ✓" % submitted_score)
			emit_signal("highscore_updated", submitted_score)
		else:
			push_error("[Leaderboard] Auth fehlgeschlagen – falsches PW oder ID")
			emit_signal("request_failed", "Auth fehlgeschlagen")
	else:
		push_error("[Leaderboard] Score-Update fehlgeschlagen (HTTP %d)" % code)
		emit_signal("request_failed", "Score-Update fehlgeschlagen (HTTP %d)" % code)

# ============================================================
#  PERSISTENZ
# ============================================================

func _save_player_data() -> void:
	var data := {
		"id":       player_id,
		"name":     player_name,
		"tag":      player_tag,
		"password": password,
		"highscore": highscore
	}
	if OS.get_name() == "Web":
		JavaScriptBridge.eval(
			"localStorage.setItem('ol_leaderboard', '%s')" % JSON.stringify(data).replace("'", "\\'")
		)
	else:
		var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if f:
			f.store_string(JSON.stringify(data))

func _load_player_data() -> Dictionary:
	if OS.get_name() == "Web":
		var raw: String = JavaScriptBridge.eval("localStorage.getItem('ol_leaderboard') || ''")
		if raw.is_empty():
			return {}
		var parsed = JSON.parse_string(raw)
		return parsed if parsed is Dictionary else {}
	else:
		if not FileAccess.file_exists(SAVE_PATH):
			return {}
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if not f:
			return {}
		var parsed = JSON.parse_string(f.get_as_text())
		return parsed if parsed is Dictionary else {}

# ============================================================
#  HTTP HELPER
# ============================================================

func _make_http() -> HTTPRequest:
	var http := HTTPRequest.new()
	add_child(http)
	return http

func _headers_get() -> Array:
	return [
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY,
	]

func _headers_post() -> Array:
	return [
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY,
		"Content-Type: application/json",
	]
