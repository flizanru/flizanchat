AddCSLuaFile("cl_chat.lua");

print("FlizanChat 2V has been successfully loaded")

local currentVersion = "2.0" 

local function chatversion()
    sql.Query("CREATE TABLE IF NOT EXISTS flizan_chat_version (version TEXT, first_load DATETIME)")

    local data = sql.Query("SELECT * FROM flizan_chat_version")

    if not data then
        sql.Query("INSERT INTO flizan_chat_version (version, first_load) VALUES ('" .. currentVersion .. "', DATETIME('now'))")
        print("[CHAT SYSTEM] The first launch! The version is set to " .. currentVersion)
    else
        local lastVersion = data[#data].version
        if lastVersion ~= currentVersion then
            sql.Query("INSERT INTO flizan_chat_version (version, first_load) VALUES ('" .. currentVersion .. "', DATETIME('now'))")
            print("[CHAT SYSTEM] A new version has been discovered! Upgrade from " .. lastVersion .. " to " .. currentVersion)
        else
            print("[CHAT SYSTEM] Launching an existing version " .. currentVersion)
        end
    end
end

chatversion()
