#load "game.jai";

current_id := 0;

EntityId :: int;
EntityMap :: Table(EntityId, *Entity);

Manager :: struct
{
	// map of entities present
	entities : EntityMap;
	// the game's window
	window : Window_Type;
	// last update time
	lastUpdateTime : float;
	// queue of entities to delete
	// TODO: use entity ptr instead of entity id???
	delete_queue : [..] EntityId;
}

make_manager :: (window : Window_Type) -> *Manager
{
	mgr : *Manager = New(Manager);
	mgr.lastUpdateTime = cast(float)get_time();
	mgr.window = window;
	return mgr;
}

manager_add_entity :: (mgr : *Manager, e : *Entity)
{
	table_add(*mgr.entities, e.id, e);
}

manager_del_entity :: (mgr : *Manager, id : EntityId)
{
	table_remove(*mgr.entities, id);
}

// TODO: rename the manager function signatures to action_manager :: (...)
manager_update :: (mgr : *Manager)
{	
	window_width, window_height = Simp.get_render_dimensions(mgr.window);
	current_time := cast(float)get_time();
	dt := current_time - mgr.lastUpdateTime;

	// delete entities which need to be removed by reffering to the manager's delete queue

	while (mgr.delete_queue.count > 0)
	{
		to_remove := mgr.delete_queue[0];
		array_unordered_remove_by_index(*mgr.delete_queue, 0);
		ptr, _ := table_find(*mgr.entities, to_remove);
		// TODO: look more into how memory management actually works in this language...
		free(ptr);
		manager_del_entity(mgr, to_remove);
	}

	// update entities
	for e, id: mgr.entities
	{
		if e.type == 
		{
			case .PLAYER;
				p : *Player = cast(*Player)e; 
				update_player(mgr, p, dt);
			case .PLAYER_BULLET;
				b : *Bullet = cast(*Bullet)e; 
				update_bullet(mgr, b, dt);
		}
	} 
	mgr.lastUpdateTime = current_time;
}

manager_draw :: (mgr : *Manager)
{
	for e, id: mgr.entities
	{
		if e.type == 
		{
			case .PLAYER;
				p : *Player = cast(*Player)e; 
				draw_player(p);
			case .PLAYER_BULLET; 
				draw_entity(e);
		}
	} 
}
