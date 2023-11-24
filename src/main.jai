#import "Window_Creation";
#import "Windows";
#import "Basic";
#import "Math";
#import "Hash_Table";

Simp :: #import "Simp";
Input :: #import "Input";

// load game logic
#load "manager.jai";

my_window: Window_Type;
window_width  : s32 = 1024;
window_height : s32 = 768;

current_time: float64;
current_dt:   float64;

main :: ()
{
    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();

        // Windows is very bad at thread-switching by default unless you do this. Sad.
       Windows.timeBeginPeriod(1);
    }
    my_window = create_window(window_width, window_height, "pogU game");

    // get window dimensions
    window_width, window_height = Simp.get_render_dimensions(my_window);

    Simp.set_render_target(my_window);
    quit := false; 
    
    // Load entity texture
    texture : *Simp.Texture = New(Simp.Texture);  
    // TODO: edit sprite again, I accidently clipped off the top of the west-facing sprite frames
    success := Simp.texture_load_from_file(texture, "resources/spr_rifleman1_strip21.png");
    assert(success);

    // TODO: figure out why this blanks out the texture loaded previously above
    // Load bullet texture
    bullet_texture : *Simp.Texture = New(Simp.Texture);  
    // // TODO: edit sprite again, I accidently clipped off the top of the west-facing sprite frames
    success = Simp.texture_load_from_file(bullet_texture, "resources/bullet.png");
    assert(success);
    
    // player sprite info
    sprite_dims := Vector2.{16.0, 16.0};
    dims := Vector2.{32.0, 32.0};
    pos := Vector2.{100.0, 100.0};
    
    sprite_indices : [..] Vector2;
    array_add(*sprite_indices, Vector2.{128.0, 16.0});
    array_add(*sprite_indices, Vector2.{0.0, 0.0});
    array_add(*sprite_indices, Vector2.{0.0, 16.0});
    array_add(*sprite_indices, Vector2.{256.0, 16.0});

    num_frames : [..] int;
    array_add(*num_frames, 4);
    array_add(*num_frames, 4);
    array_add(*num_frames, 4);
    array_add(*num_frames, 4);

    indexing_vec := Vector2.{16.0, 0.0};
    sprite_fps := 30.0;

    bullet_texture_dims := Vector2.{3.0, 6.0};
    bullet_output_dims := Vector2.{6.0, 12.0};
    bullet_pos := Vector2.{100.0, 100.0};
    
    bullet_sprite_indices : [..] Vector2;
    array_add(*bullet_sprite_indices, Vector2.{0.0, 0.0});

    bullet_num_frames : [..] int;
    array_add(*bullet_num_frames, 1);

    bullet_indexing_vec := Vector2.{16.0, 0.0};
    bullet_sprite_fps := 30.0;

    bullets : Table(BulletType, *Bullet);

    b : *Bullet = make_bullet(bullet_pos, 45.0, bullet_texture, Vector2.{cast(float)bullet_texture.width, cast(float)bullet_texture.height}, bullet_output_dims, bullet_output_dims, bullet_output_dims, bullet_sprite_indices, bullet_num_frames, bullet_indexing_vec, bullet_sprite_fps, 750.0, .PLAYER_BULLET, .BASIC);     
    table_add(*bullets, b.bullet_type, b);

    e : *Player = make_player(pos, 0.0, texture, Vector2.{cast(float)texture.width, cast(float)texture.height}, sprite_dims, dims, dims, sprite_indices, num_frames, indexing_vec, sprite_fps, 500.0, 1.0, bullets);

    m : *Manager = make_manager(my_window);
    manager_add_entity(m, cast(*Entity)e);

    // main window loop
    while !quit {
        Input.update_window_events();

        for Input.get_window_resizes() {
            Simp.update_window(it.window);  // Simp will do nothing if it doesn't care about this window.
            
            if it.window == my_window {
                should_reinit := (it.width != window_width) || (it.height != window_height);

                window_width  = it.width;
                window_height = it.height;

                // if should_reinit my_init_fonts();  // Resize the font for the new window size.
            }
        }

        for Input.events_this_frame {
            if it.type == .QUIT then quit = true;

            if it.type == {
              case .KEYBOARD;
                if it.key_pressed && it.key_code == .ESCAPE {
                    quit = true;
                }
            }
        }

        Simp.clear_render_target(.545, .674, .058, 1);

        Simp.set_shader_for_color();

        manager_draw(m);
        manager_update(m);

        Simp.swap_buffers(my_window);

        sleep_milliseconds(10);
        reset_temporary_storage();
    }
}


// draw :: () 
// {
//     Simp.clear_render_target(.12, .12, .12, 1);
    
//     Simp.set_shader_for_color();

//     time := get_time();

//     current_dt = time - current_time;
//     current_time = time;
    
//     Simp.swap_buffers(my_window);
// }