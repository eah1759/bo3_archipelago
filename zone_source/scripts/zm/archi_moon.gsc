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
    level.archi.moon_kvals = [];
    level.archi.opened_airlocks = [];
    level.archi.save_state = &save_state;
    level thread archi_save::save_on_round_change();
    level thread archi_save::round_checkpoints();

	airlock_buys = getentarray("zombie_airlock_buy", "targetname");
    for (i = 0; i < airlock_buys.size; i++)
    {
        airlock_buys[i].id = i;
    }
    array::thread_all(airlock_buys, &track_airlock_buy);

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

function track_airlock_buy()
{
    self waittill("door_opened");
    level.archi.opened_airlocks[level.archi.opened_airlocks.size] = self.id;
}

function save_state()
{
    archi_save::save_round_number();
    archi_save::save_zombie_count();
    archi_save::save_power_on();
    archi_save::save_doors_and_debris();
    archi_save::save_spent_tokens();

    save_airlocks();

    archi_save::save_players(&save_player_data);

    save_map_state();

    archi_save::send_save_data("zm_moon");

    if (level.archi.save_checkpoint == true)
    {
        IPrintLnBold("Checkpoint Saved");
    }
}

function save_airlocks()
{
    airlock_str = "";
    foreach (airlock_id in level.archi.opened_airlocks)
    {
        airlock_str += airlock_id + ";";
    }

    SetDvar("ARCHIPELAGO_SAVE_DATA_OPENED_AIRLOCKS", airlock_str);
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
    restore_airlocks();

    restore_map_state();

    wait(10);
    level flag::clear("ap_prevent_checkpoints");
}

function restore_airlocks()
{
    // Open doors
	airlock_buys = getentarray("zombie_airlock_buy", "targetname");
    airlocks_str = GetDvarString("ARCHIPELAGO_LOAD_DATA_OPENED_AIRLOCKS", "");
    IPrintLn(airlocks_str);
    if (airlocks_str != "")
    {
        airlock_ids = strtok(airlocks_str, ";");
        foreach (airlock_id_str in airlock_ids)
        {
            airlock_id = int(airlock_id_str);
            if (isdefined(airlock_buys[airlock_id]))
            {
                airlock_buys[airlock_id] notify("trigger", level.players[0], true);
            }
        }
        SetDvar("ARCHIPELAGO_LOAD_DATA_OPENED_AIRLOCKS", "");
    }
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

function play_timer_vox(digger_name)
{
    level endon("teleporter_vox_timer_stop");
    time_left = level.diggers_global_time;
    played180sec = 0;
	played120sec = 0;
	played60sec = 0;
	played30sec = 0;
	digger_start_time = gettime();
    while(time_left > 0)
	{
		curr_time = gettime();
		time_used = (curr_time - digger_start_time) / 1000;
		time_left = level.diggers_global_time - time_used;
		if(time_left <= 180 && !played180sec)
		{
			level thread play_mooncomp_vox("vox_mcomp_digger_start_", digger_name);
			played180sec = 1;
		}
		if(time_left <= 120 && !played120sec)
		{
			level thread play_mooncomp_vox("vox_mcomp_digger_start_", digger_name);
			played120sec = 1;
		}
		if(time_left <= 60 && !played60sec)
		{
			level thread play_mooncomp_vox("vox_mcomp_digger_time_60_", digger_name);
			played60sec = 1;
		}
		if(time_left <= 30 && !played30sec)
		{
			level thread play_mooncomp_vox("vox_mcomp_digger_time_30_", digger_name);
			played30sec = 1;
		}
		wait(1);
	}
}

function play_mooncomp_vox(alias, digger)
{
    if (!level.on_the_moon)
    {
        return;
    }
    num = 0; // Teleporter
    level.mooncomp_is_speaking = 1;
    level do_mooncomp_vox(alias + num);
    level.mooncomp_is_speaking = 0;
}

function do_mooncomp_vox(alias)
{
	players = getplayers();
	for(i = 0; i < players.size; i++)
	{
		if(players[i] zm_equipment::is_active(level.var_f486078e))
		{
			players[i] playsoundtoplayer(alias + "_f", players[i]);
		}
	}
	if(!isdefined(level.var_2ff0efb3))
	{
		return;
	}
	foreach(speaker in level.var_2ff0efb3)
	{
		playsoundatposition(alias, speaker.origin);
		wait(0.05);
	}
}

function patch_digger_rng()
{
    while(true)
    {
        level waittill("between_round_over");
        if (level.round_number >= 3)
        {
            wait(2);
            if(level flag::exists("teleporter_used") && level flag::get("teleporter_used"))
            {
                continue;
            }
            if(level flag::get("digger_moving"))
            {
                continue;
            }
            wait(2);
            level flag::set("start_teleporter_digger");
            level thread util::clientnotify("Dz2e");
            wait(1);
            level notify("teleporter_vox_timer_stop");
            level thread play_timer_vox("teleporter");
            return;
        }
    }
}

function setup_locations()
{
    level flag::wait_till("initial_blackscreen_passed");

    level thread patch_digger_rng();

	windows = struct::get_array("exterior_goal", "targetname");
    array::thread_all(windows, &hackable_window);

    level thread _notify_to_location_thread("packapunch_hacked", level.archi.mapString + " Hack the Pack-A-Punch Machine");
    level thread _flag_to_location_thread("override_magicbox_trigger_use", level.archi.mapString + " Hack the Mystery Box");
    level thread hacked_digger(level.archi.mapString + " Hack an Excavator");

    level thread _flag_to_location_thread("power_on", level.archi.mapString + " Turn on the Power");

    cushion_sound_triggers = getentarray("trig_cushion_sound", "targetname");
    array::thread_all(cushion_sound_triggers, &safe_landing);

    level thread _notify_kval_to_location_thread("sq_ss1_completed", level.archi.mapString + " Main Easter Egg - Samantha Says");
    level thread _notify_kval_to_location_thread("release_complete", level.archi.mapString + " Main Easter Egg - Buttons in the Lab");
    level thread _flag_to_location_thread("complete_be_1", level.archi.mapString + " Main Easter Egg - Transport the Vril Sphere to the MPD");
    level thread _flag_to_location_thread("sam_switch_thrown", level.archi.mapString + " Main Easter Egg - Open the MPD");

    level thread _flag_to_location_thread("c_built", level.archi.mapString + " Main Easter Egg - Transport the Hexagonal Plates");
    level thread _flag_to_location_thread("w_placed", level.archi.mapString + " Main Easter Egg - Plug in the Computer");
    level thread _notify_to_location_thread("kill_press_monitor", level.archi.mapString + " Main Easter Egg - Delete Maxis from the Computer");
    level thread _flag_to_location_thread("second_tanks_charged", level.archi.mapString + " Main Easter Egg - Fill all the MPD Soul Canisters");
    level thread _flag_to_location_thread("soul_swap_done", level.archi.mapString + " Main Easter Egg - Swap Souls");
    level thread _notify_to_location_thread("moon_sidequest_big_bang_achieved", level.archi.mapString + " Main Easter Egg - Nuke the Earth");
    level thread _notify_to_location_thread("moon_sidequest_big_bang_achieved", level.archi.mapString + " Main Easter Egg - Victory");

    level thread space_dog_objects(level.archi.mapString + " Space Dog - Wave Gun Target Practice");
    level thread _flag_to_location_thread("sd_hound", level.archi.mapString + " Space Dog - Wave Gun the Toy Hellhound in Area 51");
    level thread _flag_to_location_thread(array("sd_bear", "sd_bone"), level.archi.mapString + " Space Dog - Wave Gun the Teddy Bear in the Bidome and the Bone near the Teleporter");
    level thread _flag_to_location_thread("sd_large_complete", level.archi.mapString + " Space Dog - Fill the Dog Bowl with 30 Zombie Souls");
    level thread _flag_to_location_thread("sd_small_complete", level.archi.mapString + " Space Dog - Fill the Dog Bowl with 15 Hellhound Souls");

    level thread _flag_to_location_thread("snd_song_completed", level.archi.mapString + " Music EE - Coming Home");
    level music_8bit_setup();
}

function music_8bit_setup()
{
    structs = struct::get_array("8bitsongs", "targetname");
    foreach(struct in structs)
    {
        switch (struct.script_string)
        {
            case "8bit_redamned":
                level thread music_8bit_thread(level.archi.mapString + " Music EE - Re-Damned");
                break;
            case "8bit_cominghome":
                level thread music_8bit_thread(level.archi.mapString + " Music EE - Coming Home 8-Bit");
                break;
            case "8bit_pareidolia":
                level thread music_8bit_thread(level.archi.mapString + " Music EE - Pareidolia 8-Bit");
                break;
        }
    }
}

function music_8bit_thread(location)
{
    n_count = 0;
    while(true)
    {
        self waittill("trigger_activated");
		if(!is_music_ready())
		{
			continue;
		}
        n_count++;
        if (n_count >= 3)
        {
            break;
        }
    }
    archi_core::send_location(location);
}

function is_music_ready()
{
	if(isdefined(level.musicsystem.currentplaytype) && level.musicsystem.currentplaytype >= 4 || (isdefined(level.musicsystemoverride) && level.musicsystemoverride))
	{
		return false;
	}
	return true;
}

function space_dog_objects(location)
{
    s_objects = struct::get_array("sd_start", "script_noteworthy");
    a_flags = [];
    wait(10);
    foreach(s_obj in s_objects)
    {   
        IPrintLn(s_obj.targetname);
        a_flags[a_flags.size] = s_obj.targetname;
    }
    level flag::wait_till_all(a_flags);
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

function hacked_digger(location)
{
    level flag::wait_till_any(array("teleporter_digger_hacked", "teleporter_digger_hacked_before_breached", "hangar_digger_hacked", "hangar_digger_hacked_before_breached", "biodome_digger_hacked", "biodome_digger_hacked_before_breached"))
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

    if (IsArray(flag))
    {
        level flag::wait_till_all(flag);
    }
    else
    {
        level flag::wait_till(flag);
    }
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

function _notify_kval_to_location_thread(str, location)
{
    level.archi.moon_kvals[str] = 0;
    level endon("end_game");

    level waittill(str);
    archi_core::send_location(location);

    level.archi.moon_kvals[str] = 1;
    IPrintLn(str);
}

function save_map_state()
{
    save_moon_kval("sq_ss1_completed");
}

function save_moon_kval(key)
{
    archi_save::save_val(key, level.archi.moon_kvals[key]);
}

function restore_map_state()
{
    restore_moon_kval("sq_ss1_completed");
    if (has_moon_kval("sq_ss1_completed"))
    {
        level flag::wait_till("power_on");
        wait(1);
        while(true)
        {
            if (isdefined(level._ss_sequence_matched))
            {
                break;
            }
            wait(0.1);
        }
        wait(0.1);
        sq_struct = level._zombie_sidequests["sq"].stages["ss1"];
        level flag::wait_till_clear("displays_active");
        level._ss_sequence_matched = 1;
        sq_struct notify("ss_won");
    }
}

function restore_moon_kval(key)
{
    level.archi.moon_kvals[key] = archi_save::restore_val(key);
}

function has_moon_kval(key)
{
    if (isdefined(level.archi.moon_kvals[key]) && level.archi.moon_kvals[key] != 0)
    {
        return true;
    }
    return false;
}