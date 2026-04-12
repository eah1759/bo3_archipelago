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
#using scripts\zm\_zm_equipment;
#using scripts\zm\craftables\_zm_craftables;

#using scripts\zm\archi_core;
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
    archi_save::save_spent_tokens();

    archi_save::save_players(&save_player_data);

    save_map_state();

    archi_save::send_save_data("zm_moon");

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
    archi_save::wait_restore_ready("zm_moon");
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
    SetDvar("ARCHIPELAGO_CLEAR_DATA", "zm_moon");
    LUINotifyEvent(&"ap_clear_data", 0);
}

function setup_locations()
{
    level flag::wait_till("initial_blackscreen_passed");

	windows = struct::get_array("exterior_goal", "targetname");
    array::thread_all(windows, &hackable_window);

    level thread _notify_to_location_thread("packapunch_hacked", level.archi.mapString + " Hack the Pack-A-Punch Machine");
    level thread _flag_to_location_thread("override_magicbox_trigger_use", level.archi.mapString + " Hack the Mystery Box");
    level hacked_digger(level.archi.mapString + " Hack an Excavator");

    level thread _flag_to_location_thread("power_on", level.archi.mapString + " Turn on the Power");

    cushion_sound_triggers = getentarray("trig_cushion_sound", "targetname");
    array::thread_all(cushion_sound_triggers, &safe_landing);

    level thread _notify_to_location_thread("release_complete", level.archi.mapString + " Main Easter Egg - Samantha Says");
    level thread _flag_to_location_thread(level._osc_flags[9], level.archi.mapString + " Main Easter Egg - Buttons in the Lab");
    level thread _flag_to_location_thread("complete_be_1", level.archi.mapString + " Main Easter Egg - Transport the Vril Sphere to the MPD");
    level thread _flag_to_location_thread("sam_switch_thrown", level.archi.mapString + " Main Easter Egg - Open the MPD");

    level thread _flag_to_location_thread("c_built", level.archi.mapString + " Main Easter Egg - Transport the Hexagonal Plates");
    level thread _flag_to_location_thread("w_placed", level.archi.mapString + " Main Easter Egg - Plug in the Computer");
    level thread _notify_to_location_thread("kill_press_monitor", level.archi.mapString + " Main Easter Egg - Listen to Richtofen on the Computer");
    level thread _flag_to_location_thread("second_tanks_charged", level.archi.mapString + " Main Easter Egg - Fill all the MPD Soul Canisters");
    level thread _flag_to_location_thread("soul_swap_done", level.archi.mapString + " Main Easter Egg - Swap Souls");
    level thread _notify_to_location_thread("moon_sidequest_big_bang_achieved", level.archi.mapString + " Main Easter Egg - Nuke the Earth");
    level thread _notify_to_location_thread("moon_sidequest_big_bang_achieved", level.archi.mapString + " Main Easter Egg - Victory");

    foreach(player in level.players)
    {
        player thread _player_has_hacker();
    }
    callback::on_connect(&_player_has_hacker);
}

function safe_landing()
{
    level endon("ap_safe_landing");
    while(true)
    {
        self waittill("trigger", who);
        if(isplayer(who) && (isdefined(who._padded) && who._padded))
        {
           break; 
        }
    }
    archi_core::send_location(level.archi.mapString + " Land safely on a cushion");
    level notify("ap_safe_landing");
}

function _player_has_hacker()
{
    level endon("ap_has_hacker");
    while(true)
    {
        equipment = self zm_equipment::get_player_equipment();
        if(isdefined(equipment) && equipment == "equip_hacker_zm")
        {
            break;
        }
        wait(1);
    }
    archi_core::send_location(level.archi.mapString + " Pickup the Hacker");
    callback::remove_on_connect(&_player_has_hacker);
    level notify("ap_has_hacker");
}

function hacked_digger(location)
{
    level flag::wait_till_any(array("teleporter_digger_hacked", "hangar_digger_hacked", "biodome_digger_hacked"))
    archi_core::send_location(location);
}

function hackable_window()
{
    level endon("ap_window_hacked");
    self waittill("blocker_hacked");
    archi_core::send_location(level.archi.mapString + " Hack a Broken Window");
    level notify("ap_window_hacked");
}

// === AP Check Utilities ===

// Collect a check when a level flag gets set
// level thread _flag_to_location_thread("flag", level.archi.mapString + " locationName");
function _flag_to_location_thread(flag, location)
{
    level endon("end_game");

    level flag::wait_till(flag);
    archi_core::send_location(location);
}

// Collect a check when a level notification happens
// level thread _notify_to_location_thread("notification", level.archi.mapString + " locationName");
function _notify_to_location_thread(str, location)
{
    level endon("end_game");

    level waittill(str);
    archi_core::send_location(location);
}

function save_map_state()
{
    
}

function restore_map_state()
{
    
}