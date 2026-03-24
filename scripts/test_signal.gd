extends SceneTree

func _init():
    print("=== TEST: Loading game_manager.tscn ===")
    var gm_scene = load("res://scenes/game_manager.tscn")
    if gm_scene == null:
        print("ERROR: Failed to load"); quit(); return
    
    print("=== TEST: Instantiating ===")
    var gm = gm_scene.instantiate()
    root.add_child(gm)
    print("=== GM added to tree ===")
    
    # In Godot 4, _ready() should have already run synchronously after add_child
    # Let me check what children GM has
    print("GM has ", gm.get_child_count(), " children:")
    for i in range(gm.get_child_count()):
        var c = gm.get_child(i)
        print("  ", i, ": ", c.name)
    
    var ss = gm.get_node_or_null("StartScreen")
    print("StartScreen via get_node_or_null: ", ss)
    
    if ss == null:
        # Try to find it in the tree
        print("StartScreen not found! Checking all descendants...")
        print("Trying _show_start_screen manually...")
        gm._show_start_screen()
        ss = gm.get_node_or_null("StartScreen")
        print("After manual call, StartScreen: ", ss)
    
    if ss:
        print("Has mode_selected: ", ss.has_signal("mode_selected"))
        print("Calling _on_classic_pressed...")
        ss._on_classic_pressed()
        print("After _on_classic_pressed, GM children:")
        for i in range(gm.get_child_count()):
            var c = gm.get_child(i)
            print("  ", i, ": ", c.name)
    
    print("=== TEST DONE ===")
    quit()
