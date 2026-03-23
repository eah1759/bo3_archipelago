#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#using scripts\zm\_util;
#using scripts\zm\_zm_perks;

#insert scripts\shared\shared.gsh;

REGISTER_SYSTEM( "archi_staminup", &__init__, undefined )

function __init__()
{
    zm_perks::register_perk_threads("specialty_staminup", &staminup_perk_activate, &staminup_perk_lost);
}

function staminup_perk_activate()
{
    self SetPerk("specialty_unlimitedsprint");
    self.ap_staminup = 1;

    mapName = GetDvarString( "mapname" );

    switch(mapName)
    {
        case "zm_zod":
        {
            self thread beast_mode_patch();
            break;
        }
    }
}

function staminup_perk_lost(pause, perk_str, result)
{
    self UnSetPerk("specialty_unlimitedsprint");
    self.ap_staminup = 0;
    self notify("ap_staminup_lost");
}

function beast_mode_patch()
{
    self notify("ap_beastmode_patch");
    self endon("ap_beastmode_patch");
    self endon("ap_staminup_lost");

    while(true)
    {
        self flag::wait_till("in_beastmode");
        self flag::wait_till_clear("in_beastmode");
        if (self.ap_staminup == 1)
        {
            self SetPerk("specialty_unlimitedsprint");
        }
    }
}