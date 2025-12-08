extends Control

onready var lbl_name  = $PanelBackground/StatsContainer/Name/Value2
onready var lbl_speed = $PanelBackground/StatsContainer/Speed/Value2
onready var lbl_dash  = $PanelBackground/StatsContainer/DashPower/Value2

onready var lbl_collected = $PanelBackground/StatsContainer/Collected/Value2
onready var lbl_banked    = $PanelBackground/StatsContainer/Banked/Value2
onready var lbl_time      = $PanelBackground/StatsContainer/TimePlayed/Value2

func _ready():
	fetch_stats()

func fetch_stats():
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, "_on_request_completed")
	http.request("http://localhost:8080/api/stats/total")



func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Error cargando stats: ", response_code)
		return

	var data = parse_json(body.get_string_from_utf8())

	lbl_name.text      = str(data.get("player_name", "N/A"))


	lbl_collected.text = str(data.get("total_collected", 0))
	lbl_banked.text    = str(data.get("total_banked", 0))
	var raw_time = float(data.get("total_time", 0))
	var minutes = int(raw_time / 60)
	var seconds = int(raw_time) % 60
	lbl_time.text = "%02d:%02d" % [minutes, seconds]

func _on_CloseButton_pressed():
	LoadingScreen.goto_scene("res://scenes/ui/MainMenu.tscn")
