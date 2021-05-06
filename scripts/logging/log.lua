if(game:getdvar("gamemode") ~= "mp") then
    return
end

game:setdvarifuninitialized("logfile", 1)
if(tonumber(game:getdvar("logfile")) < 1) then
    return
end
game:setdvarifuninitialized("g_log", "logs/games_mp.log")

start_time = 0

function get_time()
    local seconds = math.floor((game:gettime() - start_time) / 1000)
    local minutes = math.floor(seconds / 60)
    time = string.format("%d:%02d", minutes, seconds - minutes * 60)
    while(string.len(time) < 6) do
        time = " " .. time
    end
    time = time .. " "
    return time
end

function create_path(path)
    local dir = path:gsub("%/", "\\"):match("(.*[\\])")
    os.execute("if not exist " .. dir .. " mkdir " .. dir)
end

function logPrint(message)
    local path = game:getdvar("g_log")
    local file = io.open(path, "a")
    if(file == nil) then
        create_path(path)
        file = assert(io.open(path, "a"))
    end
    file:write(get_time() .. message .. "\n")
    file:close()
end

function init()
    start_time = game:gettime()

    logPrint("------------------------------------------------------------")
    logPrint("InitGame")

    level:onnotify("connected", player_connected)

    game:onplayerdamage(player_damage)
    game:onplayerkilled(player_killed)

    level:onnotify("say", say)
    level:onnotify("say_team", say_team)

    level:onnotify("exitLevel_called", exitLevel_called)
    level:onnotify("shutdownGame_called", shutdownGame_called)
end

function player_connected(player)
    logPrint(string.format("J;%s;%i;%s", 
    player:getguid(), 
    player:getentitynumber(), 
    player.name))

    player:onnotifyonce("disconnect", function() disconnect(player) end)
end

function disconnect(player)
    logPrint(string.format("Q;%s;%i;%s", 
    player:getguid(), 
    player:getentitynumber(), 
    player.name))
end

function player_damage(_self, inflictor, attacker, damage, dflags, mod, weapon, vPoint, vDir, hitLoc)
    if(game:isplayer(attacker) == 1) then
        logPrint(string.format("D;%s;%i;%s;%s;%s;%i;%s;%s;%s;%i;%s;%s", 
        _self:getguid(), 
        _self:getentitynumber(), 
        _self.team, 
        _self.name, 
        attacker:getguid(), 
        attacker:getentitynumber(), 
        attacker.team, 
        attacker.name, 
        weapon, 
        damage, 
        mod, 
        hitLoc))
    else
        logPrint(string.format("D;%s;%i;%s;%s;%s;%i;%s;%s;%s;%i;%s;%s", 
        _self:getguid(), 
        _self:getentitynumber(), 
        _self.team, 
        _self.name, 
        "", 
        "-1", 
        "world", 
        "", 
        weapon, 
        damage, 
        mod, 
        hitLoc))
    end
end

function player_killed(_self, inflictor, attacker, damage, mod, weapon, vDir, hitLoc, psTimeOffset, deathAnimDuration)
    if(game:isplayer(attacker) == 1) then
        logPrint(string.format("K;%s;%i;%s;%s;%s;%i;%s;%s;%s;%i;%s;%s", 
        _self:getguid(), 
        _self:getentitynumber(), 
        _self.team, 
        _self.name, 
        attacker:getguid(), 
        attacker:getentitynumber(), 
        attacker.team, 
        attacker.name, 
        weapon, 
        damage, 
        mod, 
        hitLoc))
    else
        logPrint(string.format("K;%s;%i;%s;%s;%s;%i;%s;%s;%s;%i;%s;%s", 
        _self:getguid(), 
        _self:getentitynumber(), 
        _self.team, 
        _self.name, 
        "", 
        "-1", 
        "world", 
        "", 
        weapon, 
        damage, 
        mod, 
        hitLoc))
    end
end

function say(player, message)
    logPrint(string.format("say;%s;%i;%s;%s", 
    player:getguid(), 
    player:getentitynumber(), 
    player.name, 
    message))
end

function say_team(player, message)
    logPrint(string.format("say_team;%s;%i;%s;%s", 
    player:getguid(), 
    player:getentitynumber(), 
    player.name, 
    message))
end

function exitLevel_called()
    logPrint("ExitLevel: executed")
end

function shutdownGame_called()
    logPrint("ShutdownGame:")
    logPrint("------------------------------------------------------------")
end

init()