extends Label

@onready var timer = $"../Timer"
@onready var anim = $"../AnimationPlayer"


var time_played = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	text = str(time_played)
	Global.start_game.connect(_on_start_game)
	Global.game_over.connect(_on_game_over)


func _on_timer_timeout():
	time_played += .1
	time_played = snapped(time_played,.1)
	text = "Total time: " + str(time_played)


func _on_start_game():
	timer.start()
	time_played = 0.0

func _on_game_over():
	timer.stop()
	Global.total_time = time_played
	anim.play("game_over")
