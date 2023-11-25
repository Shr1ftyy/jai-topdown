// entity types
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

// bullet types
BulletType :: enum 
{
   BASIC; 
}

Entity :: struct 
{
    // entity id
    id : EntityId;
    // entity position
    using position : Vector2;
    // movement velocity
    velocity : float;
    // rotation
    rotation : float;
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

// TODO: set default fire rate on player creation
Player :: struct 
{
    using entity : Entity;
    // different bullet types -> used for accessing them when the player has a certain bullet type activated
    bullets : Table(BulletType, *Bullet);
    // default fire rate (round/s)
    default_fire_rate : float = 5.0;
    // last fire time
    last_fire_time : float;
    // hitpoints
    hp : float;
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

Bullet :: struct 
{
    using entity : Entity;
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
    // bullet type
    bullet_type : BulletType;
}

Enemy :: struct 
{
    using entity : Entity;
    hp : float;
}
