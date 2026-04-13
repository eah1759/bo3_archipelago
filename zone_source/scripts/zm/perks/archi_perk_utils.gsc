#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

function include_perk_in_random_rotation_delayed(perk)
{
	while(true)
	{
		if (isdefined(level.archi) && IS_TRUE(level.archi.wunderfizz_patched))
		{
			break;
		}
		wait(0.2);
	}

	if ( isdefined(level.archi.original_random_perk_list) )
	{
		level.archi.original_random_perk_list[level.archi.original_random_perk_list.size] = perk;
	}
}
