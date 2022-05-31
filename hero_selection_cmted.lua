function Think()
	
	gs = GetGameState()
	print( "game state: ", gs )

	if ( gs == GAME_STATE_HERO_SELECTION ) then
		gameMode = GetGameMode()
		if ( gameMode == GAMEMODE_1V1MID ) then
			print ( "1V1 MID" )
			if ( GetTeam() == TEAM_RADIANT )
			then
				print( "selecting radiant" )
				SelectHero( 0, "npc_dota_hero_lina" )
				SelectHero( 1, "npc_dota_hero_nevermore" )
				SelectHero( 2, "npc_dota_hero_lina" )
				SelectHero( 3, "npc_dota_hero_lina" )
				SelectHero( 4, "npc_dota_hero_lina" )
			elseif ( GetTeam() == TEAM_DIRE )
			then
				print( "selecting dire" )
				SelectHero( 5, "npc_dota_hero_nevermore" )
				SelectHero( 6, "npc_dota_hero_lina" )
				SelectHero( 7, "npc_dota_hero_lina" )
				SelectHero( 8, "npc_dota_hero_lina" )
				SelectHero( 9, "npc_dota_hero_lina" )
			end
		end
	end

end

function UpdateLaneAssignments()    

    if ( GetTeam() == TEAM_RADIANT )
    then
        --print( "Radiant lane assignments" );
        return {
        [1] = LANE_MID,
        [2] = LANE_BOT,
        [3] = LANE_BOT,
        [4] = LANE_BOT,
        [5] = LANE_BOT,
        };
    elseif ( GetTeam() == TEAM_DIRE )
    then
        --print( "Dire lane assignments" );
        return {
        [1] = LANE_MID,
        [2] = LANE_BOT,
        [3] = LANE_BOT,
        [4] = LANE_BOT,
        [5] = LANE_BOT,
        };
    end
end