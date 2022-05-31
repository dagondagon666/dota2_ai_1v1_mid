function BuybackUsageThink()
    local bot     = GetBot();
    local botTeam = GetTeam();

    print("Bot: ")
    print("ActiveMode: ",bot:GetActiveMode())
    print("Value: ",bot:GetActiveModeDesire());
    -- print(botTeam:GetActiveModeDesire());
end