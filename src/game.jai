#load "entities.jai";

// keys which have been held down
held_keys : [..] Input.Key_Code;

make_entity :: (position : Vector2, rotation : float, texture : *Simp.Texture, texture_dims : Vector2, sprite_dims : Vector2, output_dims : Vector2, hitbox_dims : Vector2) -> *Entity
{
    entity : *Entity = New(Entity);
    entity.x = position.x; 
    entity.y = position.y;
    entity.rotation = rotation;
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
    // Simp.immediate_begin();

    v2 :: make_vector2;

    h := v2(e.output_dims.x/2, 0);
    v := v2(0, e.output_dims.y/2);

    // rotate a vector around the origin and offset the points initialized above by it's dims
    radians := (PI / 180.0) * e.rotation;
    rotate(*h, radians);
    rotate(*v, radians);

    // h = rotate(h, radians);
    // v = rotate(v, radians);

    p0 := e.position - h - v;
    p1 := e.position + h - v;
    p2 := e.position + h + v;
    p3 := e.position - h + v;

    Simp.immediate_quad(p0, p1, p2, p3, Vector4.{1, 1, 1, 1});
    // Simp.immediate_flush();
}

make_player :: (position : Vector2, rotation : float, texture : *Simp.Texture, texture_dims : Vector2, sprite_dims : Vector2, output_dims : Vector2, hitbox_dims : Vector2, sprite_indices : [..] Vector2, num_frames : [..] int, indexing_vec : Vector2, sprite_fps : float, velocity : float, hp : float, bullets : Table(BulletType, *Bullet)) -> *Player
{
    player : *Player = New(Player);
    player.x = position.x; 
    player.y = position.y;
    player.velocity = velocity;
    player.rotation = rotation;
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
    player.last_frame_update_time = cast(float)get_time();
    player.hp = hp;
    player.bullets = bullets;

    return player;
}

update_player :: (mgr : *Manager, player : *Player, dt : float)
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

    // TODO: key indexing is wrong???
    for held_keys
    {
        if it == .ARROW_LEFT
        {
            resultant_velocity.x -= player.velocity;
            player.moving = true;
            player.current_idx = 1;
            // print("left");
        }
        if it == .ARROW_UP
        {
            resultant_velocity.y += player.velocity;
            player.moving = true;
            player.current_idx = 3;
            // print("up");
        }
        if it == .ARROW_RIGHT
        {
            resultant_velocity.x += player.velocity;
            player.moving = true;
            player.current_idx = 2;
            // print("right");
        }
        if it == .ARROW_DOWN
        {
            resultant_velocity.y -= player.velocity;
            player.moving = true;
            player.current_idx = 0;
            // print("down");
        }
        if it == .MOUSE_BUTTON_LEFT
        {
            b_type, success := table_find(*player.bullets, .BASIC);
            if (success) fire_bullet_player(mgr, b_type, player.position);
        }
    }

    // update player params - velocity and position
    resultant_velocity = unit_vector(resultant_velocity);
    resultant_velocity.x *= player.velocity;
    resultant_velocity.y *= player.velocity;

    player.x += (resultant_velocity.x) * dt;
    player.y += (resultant_velocity.y) * dt;

    // print("%\n", resultant_velocity);
    array_reset(*held_keys);

    if !player.moving return;

    delta := cast(float)get_time() - player.last_frame_update_time;

    if delta >= 1.0/cast(float)player.sprite_fps
    {
        player.current_frame += 1;
        player.current_frame = player.current_frame % (player.num_frames[player.current_frame] - 1);
        player.last_frame_update_time = cast(float)get_time();
    } 

    player.moving = false;
}

draw_player :: (player : *Player)
{
    Simp.set_shader_for_images(player.texture);
    Simp.immediate_begin();

    // TODO: use v2 :: make_vector2 instead of this (GROOOSSSS)
    bottom_left := Vector2.{player.x - player.output_dims.x/2, player.y - player.output_dims.y/2};
    top_left := Vector2.{player.x - player.output_dims.x/2, player.y + player.output_dims.y/2};
    top_right := Vector2.{player.x + player.output_dims.x/2, player.y + player.output_dims.y/2};
    bottom_right := Vector2.{player.x + player.output_dims.x/2, player.y - player.output_dims.y/2};

    texture_bl := player.sprite_indices[player.current_idx];
    if(player.current_frame > 0)
    {
        texture_bl.x += player.indexing_vec.x * player.current_frame;
        texture_bl.y += player.indexing_vec.y * player.current_frame;
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

fire_bullet_player :: (mgr : *Manager, bullet : *Bullet, spawn_pos : Vector2)
{
    new_bullet := New(Bullet);
    temporary := [size_of(Bullet)] u8;

    memcpy(new_bullet, bullet, size_of(Bullet));

    mouse_x, mouse_y := get_mouse_pointer_position(mgr.window, true);
    rot_vec : Vector2;

    rot_vec.x, rot_vec.y = cast(float)(mouse_x - spawn_pos.x), cast(float)(mouse_y - spawn_pos.y);
    v2 :: make_vector2;
    // create vector to get angle from
    rel_vec := v2(0, 1);
    // transform rotation vector to a unit vector
    rot_vec = unit_vector(rot_vec);
    // get dot product of 
    // get angle or rotation
    rotation := -(acos(dot_product(rel_vec, rot_vec)/(length(rel_vec) * length(rot_vec))) / PI) * 180.0;
    if(rot_vec.x < 0) rotation *= -1.0;

    new_bullet.position = spawn_pos;
    new_bullet.rotation = rotation;

    manager_add_entity(mgr, cast(*Entity)new_bullet);
}

make_bullet :: (position : Vector2, rotation : float, texture : *Simp.Texture, texture_dims : Vector2, sprite_dims : Vector2, output_dims : Vector2, hitbox_dims : Vector2, sprite_indices : [..] Vector2, num_frames : [..] int, indexing_vec : Vector2, sprite_fps : float, velocity : float, type : EntityType, bullet_type : BulletType) -> *Bullet
{
    bullet : *Bullet = New(Bullet);
    bullet.x = position.x; 
    bullet.y = position.y;
    bullet.velocity = velocity;
    bullet.rotation = rotation;
    bullet.texture = texture;
    bullet.texture_dims = texture_dims;
    bullet.sprite_dims = sprite_dims;
    bullet.output_dims = output_dims;
    bullet.hitbox_dims = hitbox_dims;
    bullet.destroyed = false;
    bullet.sprite_indices = sprite_indices;
    bullet.num_frames = num_frames;
    bullet.indexing_vec = indexing_vec; 
    bullet.sprite_fps = sprite_fps;
    bullet.current_idx = 0;
    bullet.current_frame = 0;
    bullet.last_frame_update_time = cast(float)get_time();
    bullet.type = type;
    bullet.bullet_type = bullet_type;

    return bullet;
}

update_bullet :: (mgr : *Manager, bullet : *Bullet, dt : float)
{
    v2 :: make_vector2;
    resultant_velocity := v2(0, 1);
    radians := (PI / 180.0) * bullet.rotation;
    rotate(*resultant_velocity, radians);
    resultant_velocity.x *= bullet.velocity;
    resultant_velocity.y *= bullet.velocity;

    bullet.x, bullet.y += resultant_velocity.x * dt, resultant_velocity.y *dt;
}