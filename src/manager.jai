#load "game.jai";

current_id := 0;

EntityId :: int;
EntityMap :: Table(EntityId, *Entity);

Manager :: struct
{
	entities : EntityMap;
	lastUpdateTime : float;
}

make_manager :: () -> *Manager
{
	mgr : *Manager = New(Manager);
	mgr.lastUpdateTime = cast(float)get_time();
	return mgr;
}

// TODO: update entities
// manager_update :: (*Manager : manager)
// {
// 	for id, entity: manager.entities
// 	{
// 		// update all entities
// 	} 
// }

manager_add_entity :: (mgr : *Manager, e : *Entity)
{
	table_add(*mgr.entities, current_id, e);
	current_id += 1;
}

// TODO: updating entities logic
manager_update :: (mgr : *Manager)
{	
	current_time := cast(float)get_time();
	dt := current_time - mgr.lastUpdateTime;

	for e, id: mgr.entities
	{
		if e.type == 
		{
			case .PLAYER;
				p : *Player = cast(*Player)e; 
				update_player(p, dt);
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
			case .ENTITY; draw_entity(e);
		}
	} 
}
