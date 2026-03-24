require("ui.t6.lobby.lobbymenubuttons_og")
require("ui.archipelago.frontend.ArchipelagoSettings")

Engine.GetRank = function()
    return 1000
end

Engine.IsItemLocked = function()
    return false
end

Engine.IsItemLockedForAll = function()
    return false
end

Engine.IsItemLockedForRank = function()
    return false
end

CoD.LobbyButtons.ZM_AP_BUTTON =
{
	stringRef = "ARCHIPELAGO",
	action =
	function(arg0, arg1, arg2, arg3, arg4)
		CoD.LobbyBase.SetLeaderActivity(arg2, CoD.LobbyBase.LeaderActivity.EDITING_GAME_RULES)
		LUI.OverrideFunction_CallOriginalFirst(OpenOverlay(arg0, "ArchipelagoSettings", arg2), "close",
		function()
			CoD.LobbyBase.ResetLeaderActivity(arg2)
		end)
	end,
	customId = "btnArchipelago",
	starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
}

CoD.LobbyButtons.AP_ZM_START_LAN_GAME = 
{
	stringRef = "MENU_START_GAME_CAPS",
	action = LobbyLANLaunchGame,
	customId = "btnStartLanGame",
	disabledFunc = MapVoteTimerActive,
	starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
}

APStartButtonDisabled = function()
	if MapVoteTimerActive() then
		return true
	end
	--TODO: enable this once i figure out how to re-run this check.
	-- local APStatus = Engine.DvarString(nil,"ARCHIPELAGO_CONNECTION_VALIDATED")
	-- Console.Print("Test")
	-- Console.Print(APStatus)
	-- if APStatus ~= "Connection: Validated" then
	-- 	return true
	-- end
	-- return false
end
	