@tool
extends Node3D
class_name ParticleNode

@export var do_explode:bool = false

func _process(delta:float)->void:
    if do_explode == true:
        explode()
        do_explode = false

func explode() -> void:
    print("Explode called")
    
    # Get the lifetimes of the particle systems
    var timeout_1 = %Slash.lifetime / 2
    var timeout_2 = %MultiExplosion.lifetime
    var timeout_3 = %BigBoomPulse.lifetime / 2
    var timeout_4 = %BigBoomPulse.lifetime
    var timeout_sound = timeout_3 + 0.2

    # Step 1: Trigger %slash
    %Slash.emitting = true
    var timer_1 = Timer.new()
    timer_1.wait_time = timeout_1
    timer_1.one_shot = true
    add_child(timer_1)
    timer_1.start()
    timer_1.timeout.connect(func():
        %Slash.emitting = false
        )
    await timer_1.timeout
    
    var timer_2 = Timer.new()
    timer_2.wait_time = timeout_2
    timer_2.one_shot = true
    add_child(timer_2)
    timer_2.start()
    %MultiExplosion.emitting = true
    timer_2.timeout.connect(func():
        %MultiExplosion.emitting = false
        )
        
    var timer_3 = Timer.new()
    timer_3.wait_time = timeout_3
    timer_3.one_shot = true
    add_child(timer_3)
    timer_3.start()
    
    var timer_4 = Timer.new()
    timer_4.wait_time = timeout_4
    timer_4.one_shot = true
    add_child(timer_4)
    timer_4.start()
    timer_3.timeout.connect(func():
        %BigBoomPulse.emitting = true
        SoundManager.play("explosion_1")
        )
        
    timer_4.timeout.connect(func():
        %BigBoomPulse.emitting = false


        )
    
