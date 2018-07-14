extends Control

export (PackedScene) var RankLabel
export (PackedScene) var NicknameLabel
export (PackedScene) var ScoreLabel

const JSON_HEADER = ["Content-Type: application/json"]
const ROOT_URL = "http://localhost:3000/"
const url = "leaderboard/top?game=gamine&limit=15"
const type_round = "&type=round"
const type_level = "&type=level"

var debug = bool(OS.get_environment("GAMINE_DEBUG"))
var rank_counter = 1
var request_round = true

# DEBUG
var content
var test_json

func _ready():
    self.popup()

# TODO: replace with global ROOT_URL
func request_leaderboard():
    $BackPanel.hide()
    self.clear_leaderboard()
    var request = ""

    if request_round:
        request = ROOT_URL + url + type_round
    else:
        request = ROOT_URL + url + type_level
    print("Requesting: " + request)
    if not debug:
        $Network.request(request, JSON_HEADER, true, HTTPClient.METHOD_GET)
    else:
        $Network.request(request, JSON_HEADER, false, HTTPClient.METHOD_GET)

func add_rank():
    var label = RankLabel.instance()
    if rank_counter < 10:  # Number padding
        label.text = "   " + str(rank_counter)
    else:
        label.text = str(rank_counter)
    $BackPanel/MainStack/ScoresContainer/RankStack.add_child(label, true)
    rank_counter += 1

func add_nickname(nickname):
    var label = NicknameLabel.instance()
    label.text = nickname
    $BackPanel/MainStack/ScoresContainer/NicknameStack.add_child(label, true)

func add_score(score):
    var label = ScoreLabel.instance()
    label.text = str(score)
    $BackPanel/MainStack/ScoresContainer/ScoreStack.add_child(label, true)

func error_status():
    $LoadingPanel/StatusText.text = "Error loading"
    $LoadingPanel/StatusText.rect_size.x = 453
    $LoadingPanel/StatusText.ALIGN_CENTER

func clear_leaderboard():
    rank_counter = 1
    for i in range($BackPanel/MainStack/ScoresContainer/RankStack.get_child_count()):
        $BackPanel/MainStack/ScoresContainer/RankStack.get_child(i).queue_free()
    for i in range($BackPanel/MainStack/ScoresContainer/NicknameStack.get_child_count()):
        $BackPanel/MainStack/ScoresContainer/NicknameStack.get_child(i).queue_free()
    for i in range($BackPanel/MainStack/ScoresContainer/ScoreStack.get_child_count()):
        $BackPanel/MainStack/ScoresContainer/ScoreStack.get_child(i).queue_free()

# --- Signals ---

func _on_Leaderboard_about_to_show():
    var file = File.new()
    file.open("res://test.json", File.READ)
    content = file.get_as_text()
    test_json = JSON.parse(content)
    request_leaderboard()

func _on_Network_request_completed(result, response_code, headers, body):
    # var json = JSON.parse(body.get_string_from_utf8())
    # if response_code == 200:
    var json = test_json
    for value in json.result.topEntries:
        var entry = value.values()
        add_rank()
        add_nickname(entry[0])
        add_score(entry[1])
    # else:
    #    error_status()
    $BackPanel.show()

func _on_TypeSwitch_pressed():
    if !$BackPanel/TypeSwitch.pressed:
        request_round = false
    else:
        request_round = true
    request_leaderboard()