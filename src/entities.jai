EntityType :: enum
{
    ENTITY;
    // TODO: add player logic
    PLAYER;
    // TODO: add enemies
    ENEMY;
    // TODO: add bullets
    PLAYER_BULLET;
    ENEMY_BULLET;
}

Entity :: struct 
{
    using position : Vector2;
    type : EntityType;
    texture_dims : Vector2;
    output_dims : Vector2;
    sprite_dims : Vector2;
    // TODO: Use points polygon hitbox instead of a rectangular one???
    hitbox_dims : Vector2;
    // TODO: Why a *pointer* to a texture???
    texture: *Simp.Texture;
    destroyed : bool;
}

Player :: struct 
{
    using entity : Entity;
    hp : float;
    // movement velocity
    velocity : float;
    // is the player moving?
    moving : bool;
    // starting positions of sprite that face different directions
    sprite_indices : [..] Vector2;
    // num frames per directions which the player is facing
    num_frames : [..] int;
    // sprite offsetting vector - used for indexing the frames for the player sprite
    indexing_vec : Vector2;
    // sprite animation fps
    sprite_fps : float;
    // current batch of sprites were are animating
    current_idx : int;
    // current frame in batch
    current_frame : int;
    // last frame update time
    last_frame_update_time : float;
}

Enemy :: struct 
{
    using entity : Entity;
    hp : float;
}