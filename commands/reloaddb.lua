local command = {}
function command.run(message, mt, overwrite)
  local authcheck = false
  if overwrite then
    authcheck = true
  else
    local cmember = message.guild:getMember(message.author)
    for i,v in ipairs(privatestuff.modroles) do
      if cmember:hasRole(v) then
        authcheck = true
      end
    end
  end
  if authcheck then
    print("authcheck passed")
    _G["privatestuff"] = dofile('privatestuff.lua')

    -- Lua implementation of PHP scandir function
    _G['scandir'] = function (directory)
      return fs.readdirSync(directory)
    end
    
    for i, v in ipairs(scandir("commands")) do
      local filename = string.sub(v, 1, -5)
      cmd[filename] = dofile('commands/' .. v)
    end
    
    print("done loading commands")
    
    _G['roles'] = dpf.loadjson(privatestuff.profile)
    
    _G['defaultjson'] = {
      roles = {},
      equipped = roles.default
    }
    
    defaultjson.roles[roles.default] = true
    
    _G['updateroles'] = function (member,uj)
      for k,v in pairs(roles.list) do
        if uj.equipped == k then
          member:addRole(v.id)
        elseif member:hasRole(v.id) and uj.equipped ~= k then
          member:removeRole(v.id)
        end
      end
    end
    
    _G['registeruser'] = function (member,uj)
      for k,v in pairs(roles.list) do
        if member:hasRole(v.id) then
          uj.roles[k] = true
          if v.subroles then
            for i,s in ipairs(v.subroles) do
              uj.roles[s] = true
              
            end
          end
        end
      end
      return uj
    end

    _G['botdebug'] = false


    _G['mentiontoid'] = function (x)
      local id = nil
      if '<@!' == string.sub(x,1,3) then
        id = string.sub(x,4,21)
      elseif x:match("^%-?%d+$") then
        id = x
      end
      
      return id
      
      
    end
    
    
    _G['usernametojson'] = function (x)
      print(x)
      for i,v in ipairs(scandir("savedata")) do
        local cuj = dpf.loadjson("savedata/"..v,defaultjson)
        if cuj.id then
          if cuj.id == x or ("<@!" .. cuj.id .. ">") == x or ("<@" .. cuj.id .. ">") == x then --prioritize id and mentions over nickname
            return "savedata/"..v
          end
        end
        if cuj.names then
          for j,w in pairs(cuj.names) do
            if string.lower(j) == string.lower(x) then
              return "savedata/"..v
            end
          end
        end
      end
    end
    
    _G['commands'] = {}
    
    _G['addcommand'] = function(trigger,commandfunction, expectedargs,force,usebypass)
      local newcommand = {}
      newcommand.trigger = prefix .. trigger
      newcommand.commandfunction = commandfunction or cmd.ping
      newcommand.expectedargs = 0 or expectedargs
      newcommand.force = force
      newcommand.usebypass = usebypass
      
      table.insert(commands, newcommand)
    end
    
    addcommand("ping",cmd.ping)
    addcommand("reloaddb",cmd.reloaddb)
    addcommand("runlua",cmd.runlua)
    addcommand("roles",cmd.roles)
    addcommand("register",cmd.register)
    addcommand("equip",cmd.equip)
    addcommand("give",cmd.give)
    addcommand("remove",cmd.remove)
  
    _G['handlemessage'] = function (message, content)
      if message.author.id ~= client.user.id or content then
        local messagecontent = content or message.content
        for i,v in ipairs(commands) do
          if string.trim(string.lower(string.sub(messagecontent, 0, #v.trigger+1))) == v.trigger then
            print("found ".. v.trigger)
            local mt = {}
            local nmt = {}
            if v.expectedargs == 0 then
              mt = string.split(string.sub(messagecontent, #v.trigger+1),"/")
              for a,b in ipairs(mt) do
                b = string.trim(b)
                nmt[a]=b
              end
            elseif v.expectedargs == 1 then
              nmt = {string.trim(string.sub(messagecontent, #v.trigger+1))}
            end --might have to expand later?
            if v.force then
              for c,d in ipairs(v.force) do
                table.insert(nmt,c,d)
              end
            end
            print("nmt: " .. inspect(nmt))
            local status, err = pcall(function ()
              v.commandfunction.run(message,nmt,v.usebypass)
            end)
            if not status then
              print("uh oh")
              message.channel:send("Oops! An error has occured! Error message: ```" .. err .. "``` (<@290582109750427648> <@298722923626364928> please fix this thanks)")
            end
            break
          end
        end
      end
    end

    print("done loading")

    if not overwrite then
      message.channel:send('All commands have been reloaded.')
    end

  else
    message.channel:send('Sorry, but only moderators can use this command!')
  end
  --print(message.author.name .. " did !reloaddb")
end
return command
  
