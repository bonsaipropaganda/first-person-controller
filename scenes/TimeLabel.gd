extends Label

@onready var timer = $"../Timer"

var time_played = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	text = str(time_played)


func _on_timer_timeout():
	time_played += .1
	time_played = snapped(time_played,.1)
	text = str(time_played)


func _on_start_target_start_game():
	timer.start()
