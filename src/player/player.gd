extends KinematicBody2D

enum STATES {
	IDLE,
	RUN,
	JUMP,
	FALL,
	HOLD,
}

export(float) var speed := 80.0
export(float) var gravity_strength := 100.0
export(float) var maximum_jump_height := 40.0

var state: int = STATES.IDLE
var velocity := Vector2.ZERO
var height_before_jump := 0.0
var gravity := gravity_strength

func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
	
	var horizontal_input := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var move_input := Vector2(horizontal_input, 0)
	
	match state:
		STATES.IDLE:
			# switch to 'run' state if movement is detected
			if move_input.length() > 0:
				_switch_state(STATES.RUN)
			
			# switch to 'jump' state if jump button is pressed
			if Input.is_action_just_pressed("jump"):
				_switch_state(STATES.JUMP)
				height_before_jump = global_position.y
				gravity = -gravity_strength
			
			# switch to 'fall' state if not on the floor
			if !is_on_floor():
				_switch_state(STATES.FALL)
				gravity = gravity_strength
			
			$AnimatedSprite.play("idle")
			
		STATES.RUN:
			# switch to 'idle' state if movement is not detected
			if move_input.length() <= 0:
				_switch_state(STATES.IDLE)
			
			# switch to 'jump' state if jump button is pressed
			if Input.is_action_just_pressed("jump"):
				_switch_state(STATES.JUMP)
				height_before_jump = global_position.y
				gravity = -gravity_strength
			
			# switch to 'fall' state if not on the floor
			if !is_on_floor():
				_switch_state(STATES.FALL)
				gravity = gravity_strength
			
			velocity = move_input.normalized() * speed
			
			$AnimatedSprite.play("run")
			
		STATES.JUMP:
			# switch to 'idle' state if maximum jump height is reached or a collision with a ceiling occurs
			if global_position.y <= (height_before_jump - maximum_jump_height) or is_on_ceiling():
				_switch_state(STATES.FALL)
				gravity = gravity_strength
			
			# switch to 'hold' state if on a wall
			if is_on_wall():
				_switch_state(STATES.HOLD)
				gravity = 0
				$HoldTimer.start()
			
			velocity = move_input.normalized() * speed
			
			$AnimatedSprite.play("jump")
		
		STATES.FALL:
			# switch to 'idle' state if on the floor
			if is_on_floor():
				_switch_state(STATES.IDLE)
			
			velocity = move_input.normalized() * speed
		
		STATES.HOLD:
			# switch to 'jump' state if the jump button is pressed
			if Input.is_action_just_pressed("jump"):
				_switch_state(STATES.JUMP)
				height_before_jump = global_position.y
				gravity = -gravity_strength
	
	# flip sprite depending on direction
	if horizontal_input < 0:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false
	
	velocity += Vector2.DOWN * gravity
	velocity = move_and_slide(velocity, Vector2.UP)

func _switch_state(new_state: int) -> void:
	state = new_state
	match new_state:
		STATES.IDLE:
			$StateLabel.text = "Idling"
		STATES.RUN:
			$StateLabel.text = "Running"
		STATES.JUMP:
			$StateLabel.text = "Jumping"
		STATES.FALL:
			$StateLabel.text = "Falling"
		STATES.HOLD:
			$StateLabel.text = "Holding"

func _on_HoldTimer_timeout() -> void:
	# on timeout if the state is still 'hold' then switch to the 'fall' state
	if state == STATES.HOLD:
		_switch_state(STATES.FALL)
		gravity = gravity_strength
