extends KinematicBody2D

enum STATES {
	IDLE,
	RUN,
	JUMP,
	FALL,
}

export(float) var speed := 80.0
export(float) var gravity := 100.0
export(float) var maximum_jump_height := 40.0

var state: int = STATES.IDLE
var velocity := Vector2.ZERO
var height_before_jump := 0.0
var horizontal_jump_velocity := Vector2.ZERO

func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
	
	var horizontal_input := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var move_input := Vector2(horizontal_input, 0)
	
	match state:
		STATES.IDLE:
			# switch to run state if move_input is detected
			if move_input.length() > 0:
				state = STATES.RUN
				$StateLabel.text = "Running"
			
			# switch to jump state if jump button is pressed
			if Input.is_action_just_pressed("jump"):
				state = STATES.JUMP
				$StateLabel.text = "Jumping"
				horizontal_jump_velocity = Vector2.ZERO
				height_before_jump = global_position.y
				gravity = -gravity
			
			$AnimatedSprite.play("idle")
			
		STATES.RUN:
			# switch to idle state if move_input is not detected
			if move_input.length() <= 0:
				state = STATES.IDLE
				$StateLabel.text = "Idling"
			
			velocity = move_input.normalized() * speed
			
			# switch to jump state if jump button is pressed
			if Input.is_action_just_pressed("jump"):
				state = STATES.JUMP
				$StateLabel.text = "Jumping"
				horizontal_jump_velocity = velocity
				height_before_jump = global_position.y
				gravity = -gravity
			
			# flip sprite depending on direction
			if horizontal_input < 0:
				$AnimatedSprite.flip_h = true
			else:
				$AnimatedSprite.flip_h = false
			
			$AnimatedSprite.play("run")
			
		STATES.JUMP:
			# switch to idle state if maximum jump height is reached or a collision with a ceiling occurs
			if global_position.y <= (height_before_jump - maximum_jump_height) or is_on_ceiling():
				state = STATES.FALL
				$StateLabel.text = "Falling"
				gravity = -gravity
			
			velocity = move_input.normalized() * speed
			
			$AnimatedSprite.play("jump")
		
		STATES.FALL:
			if is_on_floor():
				state = STATES.IDLE
				$StateLabel.text = "Idling"
			
			velocity = move_input.normalized() * speed
	
	velocity += Vector2.DOWN * gravity
	velocity = move_and_slide(velocity, Vector2.UP)
