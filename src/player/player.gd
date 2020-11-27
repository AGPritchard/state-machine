extends KinematicBody2D

enum STATES {
	IDLE,
	RUN,
	JUMP,
}

var state: int = STATES.IDLE

func _physics_process(_delta: float) -> void:
	match state:
		STATES.IDLE:
			pass
		STATES.RUN:
			pass
		STATES.JUMP:
			pass
