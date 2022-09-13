Round_array = {}
Log_file_path = "deaths_log.json"
Discord_webhook_URL = "URL"

function SendRequest()
    local deaths_data_array = {"```"}
    for player_name, player_table in pairs(Round_array) do
        table.insert(deaths_data_array, player_name .. ":\n")
        for id, num in pairs(player_table) do
            table.insert(deaths_data_array, string.format("\t%s: %i\n",id,num))
        end
    end
    table.insert(deaths_data_array,"```")
    local text = table.concat(deaths_data_array)
    if text == "``````" then
        text = "`Nobody died, yey!`"
    end
    local data = {
        username = "Barotrauma stats",
        avatar_url = "URL",
        content = text
    }
    local serialized_data = json.serialize(data)
    print(serialized_data)
    print(Networking.RequestPostHTTP(Discord_webhook_URL, serialized_data))
end

function Generate_test_data()
    Round_array['test_user']={}
    Round_array['test_user2']={}
    Round_array['test_user']['test_death']=3
    Round_array['test_user']['test+death']=5
    Round_array['test_user2']['test_death']=2
end

function Save_file()
    local deaths_array = {}
    if File.Exists(Log_file_path) then
        deaths_array = json.parse(File.Read(Log_file_path) or "{}")
    end
    print("Loading file")
    for player_name,player_table in pairs(Round_array) do
        deaths_array[player_name] = deaths_array[player_name] or {}
        for id,num in pairs(player_table) do
            deaths_array[player_name][id] = (deaths_array[player_name][id] or 0) + num
        end
    end
    File.Write(Log_file_path, json.serialize(deaths_array))
    print("Saving file")
end

Hook.Add("roundStart", "roundStart", function()
    Round_array = {}
end)

Hook.Add("roundEnd", "roundEnd", function()
    Save_file()
    SendRequest()
 end)

Hook.Add("characterDeath", "playerDeathHook", function(character, affliction)
    if character.IsPlayer then
        Round_array[character.Name] = Round_array[character.Name] or {}
        Round_array[character.Name][affliction.Identifier] = (Round_array[character.Name][affliction.Identifier] or 0) + 1
    end
end)
