extends SceneTree

func _init():
    print("=== TEST: Quick Food Chain Test ===")
    
    var main_scene = load("res://scenes/main.tscn")
    if main_scene == null:
        print("ERROR: main_scene null"); quit(); return
    
    var main = main_scene.instantiate()
    root.add_child(main)
    
    print("main added")
    
    # Give time for _ready
    var t = Timer.new()
    t.wait_time = 0.05
    t.one_shot = true
    root.add_child(t)
    t.timeout.connect(_on_timer)
    t.start()

func _on_timer():
    print("=== Timer fired ===")
    var main = root.get_node_or_null("main")
    if main == null:
        print("main null"); quit(); return
    
    var fm = main.get_node_or_null("FoodManager")
    var snake = main.get_node_or_null("Snake")
    print("FoodManager: ", fm != null)
    print("Snake: ", snake != null)
    
    if fm:
        var foods = fm.get_foods()
        print("Foods: ", foods.size())
    
    if snake:
        print("Calling initialize...")
        snake.initialize(Vector2i(10, 10), Vector2i(1, 0), 3)
        var pos = snake.get_body_positions()
        print("Snake positions: ", pos.size(), " positions=", pos)
    
    # Call start_with_mode
    print("Calling start_with_mode...")
    main.start_with_mode("classic")
    
    # Check food after start
    var t2 = Timer.new()
    t2.wait_time = 0.1
    t2.one_shot = true
    root.add_child(t2)
    t2.timeout.connect(_on_timer2)
    t2.start()

func _on_timer2():
    print("=== Timer2 fired ===")
    var main = root.get_node_or_null("main")
    var fm = main.get_node_or_null("FoodManager")
    var snake = main.get_node_or_null("Snake")
    
    if fm:
        var foods = fm.get_foods()
        print("Foods after start: ", foods.size())
        for i in range(foods.size()):
            var f = foods[i]
            if is_instance_valid(f) and f.has_method("get_grid_position"):
                print("  food ", i, " at ", f.call("get_grid_position"))
    
    # Force a food at head position and test eat
    if snake:
        var head = snake.get_head_position()
        print("Snake head: ", head)
        
        if fm:
            var foods = fm.get_foods()
            if foods.size() > 0 and is_instance_valid(foods[0]):
                var f = foods[0]
                f.call("set_grid_position", head)
                print("Moved food to head: ", head)
                
                # Now trigger eat
                main._trigger_food_at(head)
                print("Triggered _trigger_food_at")
                
                var t3 = Timer.new()
                t3.wait_time = 0.05
                t3.one_shot = true
                root.add_child(t3)
                t3.timeout.connect(_on_timer3)
                t3.start()

func _on_timer3():
    print("=== Timer3 fired - check results ===")
    var main = root.get_node_or_null("main")
    var fm = main.get_node_or_null("FoodManager")
    var snake = main.get_node_or_null("Snake")
    
    if fm:
        var foods = fm.get_foods()
        print("Foods after eat: ", foods.size())
    
    if snake:
        var pos = snake.get_body_positions()
        print("Snake positions after eat: ", pos.size())
        print("Positions: ", pos)
    
    print("=== TEST DONE ===")
    quit()
