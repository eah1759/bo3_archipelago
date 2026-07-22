#using scripts\codescripts\struct;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\animation_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\challenges_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scoreevents_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\zm_genesis_util;
#using scripts\zm\zm_genesis_vo;

#namespace namespace_44f858d8;

/*
	Name: __init__sytem__
	Namespace: namespace_44f858d8
	Checksum: 0xA9422ABB
	Offset: 0x570
	Size: 0x3B
	Parameters: 0
	Flags: AutoExec
*/
function autoexec __init__sytem__()
{
	system::register("zm_genesis_wisps", &__init__, &__main__, undefined);
}

/*
	Name: __init__
	Namespace: namespace_44f858d8
	Checksum: 0x849899EE
	Offset: 0x5B8
	Size: 0x83
	Parameters: 0
	Flags: None
*/
function __init__()
{
	clientfield::register("toplayer", "set_funfact_fx", 15000, 3, "int");
	clientfield::register("scriptmover", "wisp_fx", 15000, 2, "int");
	callback::on_disconnect(&on_player_disconnect);
}

/*
	Name: __main__
	Namespace: namespace_44f858d8
	Checksum: 0xFD7526CF
	Offset: 0x648
	Size: 0xB3
	Parameters: 0
	Flags: None
*/
function __main__()
{
	level waittill("start_zombie_round_logic");
	level flag::init("funfacts_started");
	level flag::init("funfacts_activated");
	level thread function_d1c51308();
	level thread function_bce246fa(); //init_player_specific
}

/*
	Name: on_player_disconnect
	Namespace: namespace_44f858d8
	Checksum: 0xA6142A01
	Offset: 0x708
	Size: 0x23
	Parameters: 0
	Flags: None
*/
function on_player_disconnect()
{
	self clientfield::set_to_player("set_funfact_fx", 0);
}

/*
	Name: function_d1c51308
	Namespace: namespace_44f858d8
	Checksum: 0xAD96B3E
	Offset: 0x738
	Size: 0x153
	Parameters: 0
	Flags: None
*/
function function_d1c51308()
{
	level.var_a8dc973b = [];
	level.var_a8dc973b["s_trig"] = struct::get_array("s_trig_wisp", "targetname");
	level.var_a8dc973b["s_fx"] = struct::get_array("s_fx_wisp", "targetname");
	foreach(s_trig in level.var_a8dc973b["s_trig"])
	{
		s_unitrigger = s_trig zm_unitrigger::create_unitrigger(&"", 64, &function_836f0458);
		s_unitrigger.require_look_at = 1;
	}
	level thread function_f61f49b0();
}

/*
	Name: function_f61f49b0
	Namespace: namespace_44f858d8
	Checksum: 0x4CA147C1
	Offset: 0x898
	Size: 0x277
	Parameters: 0
	Flags: None
*/
function function_f61f49b0()
{
	var_96cdbf35 = Array("abcd", "abcd", "shad"); //special round
	var_6cf8e556 = Array("shad", "abcd"); //boss round
	while(1)
	{
		str_notify = level util::waittill_any_return("wisps_on_abcd", "wisps_on_shad", "boss_round_end_vo_done", "chaos_round_end_vo_done", "wisps_off");
		if(str_notify == "wisps_on_abcd")
		{
			namespace_c149ef1::function_4821b1a3("abcd"); // new wisp fx set setup (zm_genesis_voi.gsc)
			function_719d3043(1, "abcd"); //setup triggers
		}
		else if(str_notify == "wisps_on_shad")
		{
			namespace_c149ef1::function_4821b1a3("shad"); // new wisp fx set setup (zm_genesis_voi.gsc)
			function_719d3043(1, "shad"); //setup triggers
		}
		else if(str_notify == "boss_round_end_vo_done" && var_6cf8e556.size > 0)
		{
			var_effd4dcc = var_6cf8e556[0];
			namespace_c149ef1::function_4821b1a3(var_effd4dcc); // new wisp fx set setup (zm_genesis_voi.gsc) // ArrayRemoveIndex(level.var_8c92b387["wisp_shad"/"wisp_abcd"], 0);
			function_719d3043(1, var_effd4dcc); //setup triggers
			ArrayRemoveIndex(var_6cf8e556, 0, 0);
		}
		else if(str_notify == "chaos_round_end_vo_done" && var_96cdbf35.size > 0)
		{
			var_effd4dcc = var_96cdbf35[0];
			namespace_c149ef1::function_4821b1a3(var_effd4dcc); // new wisp fx set setup (zm_genesis_voi.gsc)
			function_719d3043(1, var_effd4dcc); //setup triggers
			ArrayRemoveIndex(var_96cdbf35, 0, 0);
		}
		else if(str_notify == "wisps_off")
		{
			function_719d3043(0, undefined); //remove triggers
		}
	}
}

/*
	Name: function_719d3043
	Namespace: namespace_44f858d8
	Checksum: 0x40D31599
	Offset: 0xB18
	Size: 0x1C1
	Parameters: 2
	Flags: None
*/
function function_719d3043(b_on, var_46866c13)
{
	if(!isdefined(b_on))
	{
		b_on = 1;
	}
	if(b_on)
	{
		level.var_c1feb276 = "wisp_" + var_46866c13;
		foreach(s_trig in level.var_a8dc973b["s_trig"])
		{
			s_trig thread function_26ed5998(1, var_46866c13); //setup triggers
		}
		break;
	}
	level.var_11db95ba = "wisp_off";
	foreach(s_trig in level.var_a8dc973b["s_trig"])
	{
		s_trig thread function_26ed5998(0, var_46866c13); //remove triggers
	}
}

/*
	Name: function_26ed5998
	Namespace: namespace_44f858d8
	Checksum: 0x4E86553A
	Offset: 0xCE8
	Size: 0x193
	Parameters: 2
	Flags: None
*/
function function_26ed5998(b_on, var_46866c13)
{
	if(!isdefined(b_on))
	{
		b_on = 1;
	}
	if(!isdefined(var_46866c13))
	{
		var_46866c13 = "abcd";
	}
	var_c4217816 = [];
	var_c4217816["abcd"] = 1;
	var_c4217816["shad"] = 2;
	if(isdefined(self))
	{
		if(b_on && !isdefined(self.var_3dc2890d))
		{
			s_fx = struct::get(self.target, "targetname");
			self.var_3dc2890d = util::spawn_model("tag_origin", s_fx.origin, s_fx.angles);
			self.var_3dc2890d clientfield::set("wisp_fx", var_c4217816[var_46866c13]);
			self.s_unitrigger.b_on = 1;
			self thread function_3bcaa1c(); //wait for trigger to play wisp audio
		}
		else if(isdefined(self.var_3dc2890d))
		{
			self.var_3dc2890d delete();
			self notify("hash_d8f13b7d");
			self.s_unitrigger.b_on = 0;
		}
	}
}

/*
	Name: function_3bcaa1c
	Namespace: namespace_44f858d8
	Checksum: 0xCD548E67
	Offset: 0xE88
	Size: 0xD7
	Parameters: 0
	Flags: None
*/
function function_3bcaa1c() //shad/abcd wisp
{
	self endon("hash_d8f13b7d");
	while(1)
	{
		self waittill("trigger_activated", e_player);
		if(level.var_c1feb276 != "off" && !level flag::get("abcd_speaking") && !level flag::get("shadowman_speaking"))
		{
            level notify("ap_wisp_" + level.var_c1feb276); // send the notifier out. "wisp_abcd"/"wisp_shad"
			level thread namespace_c149ef1::function_10b9b50e(level.var_c1feb276);
			self thread function_26ed5998(0);
		}
	}
}

/*
	Name: function_836f0458
	Namespace: namespace_44f858d8
	Checksum: 0x445DF987
	Offset: 0xF68
	Size: 0x97
	Parameters: 1
	Flags: None
*/
function function_836f0458(e_player)
{
	if(isdefined(self.stub.b_on) && self.stub.b_on && level.var_c1feb276 !== "off")
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

/*
	Name: function_bce246fa
	Namespace: namespace_44f858d8
	Checksum: 0x47274CBB
	Offset: 0x1008
	Size: 0x2FB
	Parameters: 0
	Flags: None
*/
function function_bce246fa() //init_player_specific
{
	level.var_e2304a21 = []; //player specific wisp info
	level.var_e2304a21["s_trig"] = [];
	level.var_e2304a21["s_trig"][0] = struct::get("s_trig_funfact_demp", "targetname");
	level.var_e2304a21["s_trig"][1] = struct::get("s_trig_funfact_niko", "targetname");
	level.var_e2304a21["s_trig"][2] = struct::get("s_trig_funfact_rich", "targetname");
	level.var_e2304a21["s_trig"][3] = struct::get("s_trig_funfact_take", "targetname");
	level.var_e2304a21["s_fx"] = [];
	level.var_e2304a21["s_fx"][0] = struct::get("s_fx_funfact_demp", "targetname");
	level.var_e2304a21["s_fx"][1] = struct::get("s_fx_funfact_niko", "targetname");
	level.var_e2304a21["s_fx"][2] = struct::get("s_fx_funfact_rich", "targetname");
	level.var_e2304a21["s_fx"][3] = struct::get("s_fx_funfact_take", "targetname");
	foreach(s_trig in level.var_e2304a21["s_trig"])//player specific wisp triggers
	{
		s_unitrigger = s_trig zm_unitrigger::create_unitrigger(&"", 64, &function_caef395a);
		s_unitrigger.require_look_at = 1;
		s_unitrigger.script_int = s_trig.script_int;
	}
	level thread function_b177eb62(); //player specific wisp spawn conditions
}

/*
	Name: function_b177eb62
	Namespace: namespace_44f858d8
	Checksum: 0x63526D55
	Offset: 0x1310
	Size: 0xBF
	Parameters: 0
	Flags: None
*/
function function_b177eb62() //player specific wisp spawn conditions
{
	var_76bf4ac6 = level.var_783db6ab; //? I think this is the first special round...
	while(1)
	{
		level util::waittill_any_return("start_of_round");
		if(level.round_number > var_76bf4ac6)
		{
			while(level flag::get("abcd_speaking") || level flag::get("shadowman_speaking"))
			{
				wait(0.1);
			}
			level thread function_cf810f3f(1); //spawn player specific wisp?
		}
	}
}

/*
	Name: function_cf810f3f
	Namespace: namespace_44f858d8
	Checksum: 0xEA42DD23
	Offset: 0x13D8
	Size: 0xB1
	Parameters: 1
	Flags: None
*/
function function_cf810f3f(b_on) //spawn player specific wisp? self is level
{
	if(!isdefined(b_on))
	{
		b_on = 1;
	}
	foreach(s_trig in level.var_e2304a21["s_trig"]) //player specific wisp info
	{
		s_trig thread function_584171ff(b_on);
	}
}

/*
	Name: function_584171ff
	Namespace: namespace_44f858d8
	Checksum: 0xE163B0E0
	Offset: 0x1498
	Size: 0x15D
	Parameters: 1
	Flags: None
*/
function function_584171ff(b_on) //self is player specific wisp trigger struct
{
	if(!isdefined(b_on))
	{
		b_on = 1;
	}
	if(isdefined(self))
	{
		if(b_on && !(isdefined(self.s_unitrigger.b_on) && self.s_unitrigger.b_on) && level.var_8c92b387["fun_facts"][self.script_int].size > 0)
		{
			//if specific player still has wisp audios left
			e_player = zm_utility::get_specific_character(self.script_int);
			if(isdefined(e_player))
			{
				e_player thread function_2c251c80(1); //setup fun fact?
			}
			self.s_unitrigger.b_on = 1;
			self thread function_198aed06(); //wait for fun fact trigger
		}
		else if(!b_on)
		{
			e_player = zm_utility::get_specific_character(self.script_int);
			if(isdefined(e_player))
			{
				e_player thread function_2c251c80(0); //remove the fun fact?
			}
			self.s_unitrigger.b_on = 0;
			self notify("hash_d8f13b7d");
		}
	}
}

/*
	Name: function_2c251c80
	Namespace: namespace_44f858d8
	Checksum: 0xE70B12F
	Offset: 0x1600
	Size: 0x83
	Parameters: 1
	Flags: None
*/
function function_2c251c80(b_on)
{
	if(!isdefined(b_on))
	{
		b_on = 1;
	}
	if(b_on)
	{
		var_f111a90b = self.characterindex + 1;
		self clientfield::set_to_player("set_funfact_fx", var_f111a90b);
	}
	else
	{
		self clientfield::set_to_player("set_funfact_fx", 0);
	}
}

/*
	Name: function_198aed06
	Namespace: namespace_44f858d8
	Checksum: 0xE8F4EC44
	Offset: 0x1690
	Size: 0x1B7
	Parameters: 0
	Flags: None
*/
function function_198aed06()
{
	self endon("hash_77f5f32b");
	while(1)
	{
		self waittill("trigger_activated", e_player);
		if(self.script_int == e_player.characterindex && !level flag::get("abcd_speaking") && !level flag::get("shadowman_speaking"))
		{
            level notify("ap_wisp_player_" + self.script_int); //archi_genesis will have to keep track of count; I ain't touching the vo script :P
			self thread function_584171ff(0);
			if(!level flag::get("funfacts_started"))
			{
				level thread namespace_c149ef1::function_36734069();
				level flag::set("funfacts_started");
			}
			else if(!level flag::get("funfacts_activated"))
			{
				level flag::set("funfacts_activated");
				level namespace_c149ef1::function_2050fb34();
				level thread namespace_c149ef1::function_bbeae714(e_player.characterindex);
			}
			else
			{
				level thread namespace_c149ef1::function_bbeae714(e_player.characterindex);
			}
		}
	}
}

/*
	Name: function_caef395a
	Namespace: namespace_44f858d8
	Checksum: 0x9105C1F1
	Offset: 0x1850
	Size: 0xC7
	Parameters: 1
	Flags: None
*/
function function_caef395a(e_player)
{
	if(isdefined(self.stub.b_on) && self.stub.b_on)
	{
		if(self.stub.script_int == e_player.characterindex)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return 0;
	}
}