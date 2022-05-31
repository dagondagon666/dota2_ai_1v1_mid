local data;
local game_id = math.random(100000000000);
local lastUpdate = -200;
local next_data = {};
local fightLoc = nil; -- center point of fighting location
local fightAreaRadius = 0; -- radius of the location where to remove trees
local cutting = false;

function Think()
	local npcBot = GetBot();
    -- if (GetTeam() == 3) then
    --     return;
    -- end
    if npcBot:GetUnitName() ~= "npc_dota_hero_nevermore" then
        if npcBot:GetUnitName() == "npc_dota_hero_drow_ranger" then
            if npcBot:GetAbilityPoints() > 0 then
                npcBot:ActionImmediate_LevelAbility("drow_ranger_frost_arrows");
                npcBot:GetAbilityByName("drow_ranger_frost_arrows"):ToggleAutoCast();
            end
            -- npcBot:Action_MoveToLocation(Vector(0,0));
        -- Keep first dire hero there and auto attack after other heroes are gone
        elseif npcBot:GetPlayerID() == 5 then
            if DotaTime() > -80 then
                nearbyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

                hero = nearbyHeroes[1];
                for i, hero in ipairs(nearbyHeroes) do
                    if hero:GetPlayerID() == 1 then
                        npcBot:Action_AttackUnit(hero, true);
                    end
                end
            end
        else
            npcBot:Action_MoveToLocation(Vector(1600,1000));
            -- print(GetAncient(1):GetLocation());
        end
    end
    
    if DotaTime() < 0 and npcBot:GetPlayerID() ~= 5 and npcBot:GetUnitName() ~= "npc_dota_hero_drow_ranger" then
        if GetTeam() == 2 then
            npcBot:Action_MoveToLocation(Vector(1600,1000));
        else
            npcBot:Action_MoveToLocation(Vector(1600,1000));
        end
    end

	-- only handles drawranger
    if (npcBot:GetUnitName() ~= "npc_dota_hero_drow_ranger") then
        return;
	end
    -- print("DR mode")

    -- Getting Enemy data:
    local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);
    for i, enemyHero in ipairs(enemyHeroes) do
        if enemyHero:GetPlayerID() == 5 then
            target_enemy_hero = enemyHero
            enemy_location = enemyHero:GetLocation();
            enemy_facing = enemyHero:GetFacing();
            enemy_speed = enemyHero:GetCurrentMovementSpeed();
            enemy_mana = enemyHero:GetMana();
            enemy_health = enemyHero:GetHealth();
            enemy_max_health = enemyHero:GetMaxHealth();
            if enemyHero:IsAlive() then
                enemy_alive = 1
            else
                enemy_alive = 0
            end
        end
    end

    if npcBot:IsAlive() then
        alive = 1
    else
        alive = 0
    end

    data = {
        time = DotaTime(), 
        team = GetTeam(),
        location = npcBot:GetLocation(),
        speed = npcBot:GetCurrentMovementSpeed(),
        facing = npcBot:GetFacing(),
        mana = npcBot:GetMana(),
        health = npcBot:GetHealth(),
        max_health = npcBot:GetMaxHealth(),
        alive = alive,
        enemy_location = enemy_location,
        enemy_speed = enemy_speed,
        enemy_facing = enemy_facing,
        enemy_mana = enemy_mana,
        enemy_health = enemy_health,
        enemy_max_health = enemy_max_health,
        enemy_alive = enemy_alive,
        hero_id = '"'..npcBot:GetPlayerID() .. game_id..'"'
    };

    -- print(data)
    -- print(DotaTime());
    -- print(lastUpdate);

    if DotaTime() - lastUpdate > 0.2 then
        -- print("thinking")
        if next_data["direction1"] ~= nil then
            print("direction1:", next_data["direction1"])
            print("direction2:", next_data["direction2"])
            if next_data["direction1"] == 0 and next_data["direction2"] == 0 then
                -- perform attack
                npcBot:Action_AttackUnit(target_enemy_hero, true);
            else
                local x = next_data["direction1"] * 500
                local y = next_data["direction2"] * 500
                local next_location = Vector(x,y) + data["location"]
                data["next_location"] = next_location
                -- print(next_location)
                --[[
                print(next_location)
                print(next_data["time"])
                print(DotaTime())
                --]]
                npcBot:Action_MoveToLocation(next_location)
            end
        end
        lastUpdate = DotaTime()
        
        local json = '{"data":{'
        local count = 1
        for key, value in pairs(data) do
            local str = value
            if type(str) == 'userdata' then
                str = str:__tostring()
                pos = str:find('%[')
                str = str:sub(pos)
                str = string.gsub(str, " ", ",")
            end
            if count > 1 then json = json..',' end
            json = json .. '"' .. key .. '": ' .. str
            count = count + 1
        end
        json = json..'}}'
        print( json )

        if lastUpdate > -200 then
            -- offline dummy test
            -- action_table = {'00','01','02','10','11','12','20','21','22','11','11','11','11'}
            -- next_data_action = action_table[math.random(13)]

            -- next_data = {}
            -- next_data["time"] = DotaTime();
            -- next_data["direction1"] = string.sub(next_data_action,1,1) - 1
            -- next_data["direction2"] = string.sub(next_data_action,2,2) - 1
            -- print(next_data["direction1"],next_data["direction2"])
            if vpgameai~= nil then
                local data = vpgameai.get_action_from_ai_server(json);
                handle_ai_server_response(data)
            else
                local req = CreateHTTPRequest( ":12345" )
                req:SetHTTPRequestRawPostBody("application/json", json)
                req:Send( function( result )
                    handle_ai_server_response(result["Body"])
                end)
            end
        end
    end
end

function handle_ai_server_response(data)
    data = string.gsub(string.gsub(data, ':', "="), '"', '')
    local temp = load("return "..(data))()
    for k,v in pairs( temp ) do
        if k == "direction1" then
            next_data["direction1"] = v;
            next_data["time"] = DotaTime();
        end
        if k == "direction2" then
            next_data["direction2"] = v;
        end
    end
    return;
end