extends KinematicBody2D

enum STATES {
	IDLE,
	RUN,
	JUMP,
}

export(float) var speed := 200.0

var state: int = STATES.IDLE

var velocity := Vector2.ZERO

func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
	
	var horizontal_input := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var move_input := Vector2(horizontal_input, 0)
	
	match state:
		STATES.IDLE:
			# switch to run state if move_input is detected
			if move_input.length() > 0:
				state = STATES.RUN
				
			# switch to jump state if jump button is pressed
			if Input.is_action_just_pressed("jump"):
				state = STATES.JUMP
			
		STATES.RUN:
			# switch to idle state if move_input is not detected
			if move_input.length() <= 0:
				state = STATES.IDLE
			
			velocity = move_input.normalized() * speed
			
		STATES.JUMP:
			state = STATES.IDLE

	velocity = move_and_slide(velocity)
