#load "entities.jai";

// keys which have been held down
held_keys : [..] Input.Key_Code;

make_entity :: (position : Vector2, texture : *Simp.Texture, texture_dims : Vector2, sprite_dims : Vector2, output_dims : Vector2, hitbox_dims : Vector2) -> *Entity
{
    entity : *Entity = New(Entity);
    entity.x = position.x; 
    entity.y = position.y;
    entity.texture = texture;
    entity.texture_dims = texture_dims;
    entity.sprite_dims = sprite_dims;
    entity.output_dims = output_dims;
    entity.hitbox_dims = hitbox_dims;
    entity.destroyed = false;
    entity.type = .ENTITY;
    
    return entity;
}

draw_entity :: (e : *Entity)
{
    Simp.set_shader_for_images(e.texture);
    Simp.immediate_begin();

    v2 :: make_vector2;
    Simp.immediate_quad(v2(0, 0), v2(cast(float)e.texture.width, 0), v2(cast(float)e.texture.width, cast(float)e.texture.height), v2(0, cast(float)e.texture.height));
    Simp.immediate_flush();
}

make_player :: (position : Vector2, texture : *Simp.Texture, texture_dims : Vector2, sprite_dims : Vector2, output_dims : Vector2, hitbox_dims : Vector2, sprite_indices : [..] Vector2, num_frames : [..] int, indexing_vec : Vector2, sprite_fps : float, velocity : float) -> *Player
{
    player : *Player = New(Player);
    player.x = position.x; 
    player.y = position.y;
    player.velocity = velocity;
    player.texture = texture;
    player.texture_dims = texture_dims;
    player.sprite_dims = sprite_dims;
    player.output_dims = output_dims;
    player.hitbox_dims = hitbox_dims;
    player.destroyed = false;
    player.moving = false;
    player.sprite_indices = sprite_indices;
    player.num_frames = num_frames;
    player.indexing_vec = indexing_vec; 
    player.sprite_fps = sprite_fps;
    player.type = .PLAYER;
    player.current_idx = 0;
    player.current_frame = 0;

    return player;
}

update_player :: (player : *Player, dt : float)
{   
    resultant_velocity := Vector2.{0.0, 0.0};
    
    // TODO: is there a cleaner way to do this lmao? 
    for Input.input_button_states
    {
        if it & .DOWN
        {
            array_add(*held_keys, cast(Input.Key_Code)it_index);
        }
    }

    for held_keys
    {
        if it == .ARROW_LEFT
        {
            resultant_velocity.x -= player.velocity;
            player.moving = true;
            // print("left");
        }
        if it == .ARROW_UP
        {
            resultant_velocity.y += player.velocity;
            player.moving = true;
            // print("up");
        }
        if it == .ARROW_RIGHT
        {
            resultant_velocity.x += player.velocity;
            player.moving = true;
            // print("right");
        }
        if it == .ARROW_DOWN
        {
            resultant_velocity.y -= player.velocity;
            player.moving = true;
            // print("down");
        }
    }


    resultant_velocity = unit_vector(resultant_velocity);
    resultant_velocity.x *= player.velocity;
    resultant_velocity.y *= player.velocity;

    player.x += (resultant_velocity.x) * dt;
    player.y += (resultant_velocity.y) * dt;

    // print("%\n", resultant_velocity);
    array_reset(*held_keys);

    if(!player.moving) return;
}

// TODO: add animations
draw_player :: (player : *Player)
{
    Simp.set_shader_for_images(player.texture);
    Simp.immediate_begin();

    bottom_left := Vector2.{player.x - player.output_dims.x/2, player.y - player.output_dims.y/2};
    top_left := Vector2.{player.x - player.output_dims.x/2, player.y + player.output_dims.y/2};
    top_right := Vector2.{player.x + player.output_dims.x/2, player.y + player.output_dims.y/2};
    bottom_right := Vector2.{player.x + player.output_dims.x/2, player.y - player.output_dims.y/2};

    texture_bl := player.sprite_indices[player.current_idx];
    if(player.current_frame > 0)
    {
        texture_bl.x += player.indexing_vec.x + player.current_frame;
        texture_bl.y += player.indexing_vec.y + player.current_frame;
    }
    texture_bl.x /= player.texture.width;
    texture_bl.y /= player.texture.height;

    texture_tl := player.sprite_indices[player.current_idx];
    if(player.current_frame > 0)
    {
        texture_tl.x += player.indexing_vec.x * player.current_frame;
        texture_tl.y += player.indexing_vec.y * player.current_frame;
    }
    texture_tl.y += player.sprite_dims.y;
    texture_tl.x /= player.texture.width;
    texture_tl.y /= player.texture.height;

    texture_tr := player.sprite_indices[player.current_idx];
    if(player.current_frame > 0)
    {
        texture_tr.x += player.indexing_vec.x * player.current_frame;
        texture_tr.y += player.indexing_vec.y * player.current_frame;
    }
    texture_tr.x += player.sprite_dims.x;
    texture_tr.y += player.sprite_dims.y;
    texture_tr.x /= player.texture.width;
    texture_tr.y /= player.texture.height;

    texture_br := player.sprite_indices[player.current_idx];
    if(player.current_frame > 0)
    {
        texture_br.x += player.indexing_vec.x * player.current_frame;
        texture_br.y += player.indexing_vec.y * player.current_frame;
    }
    texture_br.x += player.sprite_dims.x;
    texture_br.x /= player.texture.width;
    texture_br.y /= player.texture.height;

    Simp.immediate_quad(bottom_left, bottom_right, top_right, top_left, Vector4.{1,1,1,1},
                   texture_bl, texture_br, texture_tr, texture_tl);

    Simp.immediate_flush();  
}