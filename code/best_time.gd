extends Label

var best_time: float
@onready var time_label = $"../TimeLabel"
var total_time


func _ready():
	Global.game_over.connect(_on_game_over)

func _on_game_over():
	total_time = time_label.time_played
	if !best_time:
		best_time = total_time
	else:
		if total_time < best_time:
			best_time = total_time
	text = "Best time: " + str(best_time)
