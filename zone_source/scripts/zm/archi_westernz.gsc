#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\util_shared;
#using scripts\shared\player_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\hud_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_weapons;
#using scripts\zm\craftables\_zm_craftables;

#using scripts\zm\archi_core;
#using scripts\zm\archi_items;
#using scripts\zm\archi_save;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\archi_core.gsh;

function save_state_manager()
{
    level.archi.save_state = &save_state;
    level thread archi_save::save_on_round_change();
    level thread archi_save::round_checkpoints();
    level waittill("end_game");

    if (isdefined(level.host_ended_game) && level.host_ended_game == 1)
    {
        IPrintLn("Host ended game, saving data...");
        save_state();
    } else {
        IPrintLn("Host did not end game, clearing data...");
        clear_state();
    }
}

function save_state()
{
    archi_save::save_round_number();
    archi_save::save_zombie_count();
    archi_save::save_power_on();
    archi_save::save_doors_and_debris();

    archi_save::save_players(&save_player_data);

    save_map_state();

    archi_save::send_save_data("zm_westernz");

    if (level.archi.save_checkpoint == true)
    {
        IPrintLnBold("Checkpoint Saved");
    }
}

// self is player
function save_player_data(xuid)
{  
    self archi_save::save_player_score(xuid);
    self archi_save::save_player_perks(xuid);
    self archi_save::save_player_loadout(xuid);
    
}

function load_state()
{
    level.archi.zm_castle_landingpads = 0;
    archi_save::wait_restore_ready("zm_westernz");
    level flag::wait_till("ap_attachment_rando_ready");
    archi_save::restore_zombie_count();
    archi_save::restore_round_number();
    archi_save::restore_power_on();
    archi_save::restore_doors_and_debris();

    restore_map_state();

    wait(10);
    level flag::clear("ap_prevent_checkpoints");
}

// self is player
function restore_player_data(xuid)
{
    level endon("end_game");
    self endon("disconnect");

    if (self archi_save::can_restore_player(xuid))
    {
        self archi_save::restore_player_score(xuid);
        self archi_save::restore_player_perks(xuid);
        self archi_save::restore_player_loadout(xuid);
    }
}

function clear_state()
{
    SetDvar("ARCHIPELAGO_CLEAR_DATA", "zm_westernz");
    LUINotifyEvent(&"ap_clear_data", 0);
}

function setup_locations()
{
    // Fix uninitialised flag
    level flag::init("boss_completed");

    level flag::wait_till("initial_blackscreen_passed");

    level thread find_the_skulls(level.archi.mapString + " Collect the Skulls");
    zm_spawner::register_zombie_death_event_callback(&_track_werewolf_death);
    level thread _notify_to_location_thread("exploderdelorean_lights", level.archi.mapString + " Kill a Werewolf");
    level thread _flag_to_location_thread("nixie_puzzle_solved", level.archi.mapString + " Open the Weapon Safe");

    foreach(player in level.players)
    {
        player thread _player_magmagat();
        player thread _player_greatscott();
    }
    callback::on_connect(&_player_magmagat);
    callback::on_connect(&_player_greatscott);

    level thread _flag_to_location_thread("church_enter", level.archi.mapString + " Main Easter Egg - Enter the Church"); // Check keys first
    level thread _cf_to_location_thread("ee_item_2", level.archi.mapString + " Main Easter Egg - Fill a Totem Pole with Souls", 2);
    level thread _cf_to_location_thread("ee_item_3", level.archi.mapString + " Main Easter Egg - Fill a Totem Pole with Souls", 2);
    level thread _flag_to_location_thread("boss_completed", level.archi.mapString + " Main Easter Egg - Kill Arthur Leroy");
    level thread _notify_to_location_thread("exploderdelorean_lights", level.archi.mapString + " Main Easter Egg - Back to the Future"); // Bad
}

function _flag_to_location_thread(flag, location)
{
    level endon("end_game");

    level flag::wait_till(flag);
    archi_core::send_location(location);
}

function _notify_to_location_thread(str, location)
{
    level endon("end_game");

    level waittill(str);
    archi_core::send_location(location);
}

function _cf_to_location_thread(fieldName, location, timer)
{
    while(true)
    {
        val = level clientfield::get(fieldName);
        if (val > 0)
        {
            break;
        }
        wait(timer);
    }
    archi_core::send_location(location);
}

function _track_werewolf_death(e_attacker)
{
    IPrintLn(self.archetype);
}

function _player_magmagat()
{
    self thread _player_weapon_to_thread("t8_shotgun_magmagat", level.archi.mapString + " Build the Magmagat");
}

function _player_greatscott()
{
    self thread _player_weapon_to_thread("doc_w1866", level.archi.mapString + " Pickup the Great Scott Weapon");
}

function _player_weapon_to_thread(weaponname, location)
{
    level endon("end_game");
    self endon("disconnect");

    while(true)
    {
        self waittill("weapon_change", weapon);
        if (weapon.name == weaponname)
        {
            break;
        }
    }
    archi_core::send_location(location);
}

function find_the_skulls(location)
{
    skulls = GetEntArray("skulls", "targetname");
    array::thread_all(skulls, &_skull_trigger);
    count = 0;
    while(true)
    {
        level waittill("ap_skull_collected");
        count++;

        if (count >= 2)
        {
            break;
        }
    }

    archi_core::send_location(location);
}

function _skull_trigger()
{
    self waittill("trigger", player);
    level notify("ap_skull_collected");
}

function give_ShieldPart_Dolly()
{
    archi_items::give_piece("craft_westernshield", "part_0");
}

function give_ShieldPart_Door()
{
    archi_items::give_piece("craft_westernshield", "part_1");
}

function give_ShieldPart_Clamp()
{
    archi_items::give_piece("craft_westernshield", "part_2");
}

function give_BlundergatPart_Engine()
{
    archi_items::give_piece("craft_westernshield", "part_1");
}

function give_BlundergatPart_Acid()
{
    archi_items::give_piece("craft_westernshield", "part_2");
}

function save_map_state()
{

}

function restore_map_state()
{

}