local command = {}
function command.run(message, mt, overwrite)
  local authcheck
  if overwrite then
    authcheck = true
  else
    local cmember = message.guild:getMember(message.author)
    authcheck = cmember:hasRole(privatestuff.modroleid)
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

    for i, v in ipairs(scandir("reactions")) do
      local filename = string.sub(v, 1, -5)
      cmdre[filename] = dofile('reactions/' .. v)
    end

    print("done loading reactions")
    
    _G['roles'] = dpf.loadjson(privatestuff.profile)
    
    
    
    _G['defaultjson'] = {
      roles = {
        
      },
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
    

    _G['botdebug'] = false


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
    _G['ynbuttons'] = function(message, content, etype, data, yesoption, nooption)
      yesoption = yesoption or "Yes"
      nooption = nooption or "No"
      local messagecontent, messageembed
      if type(content) == "table" then
        messageembed = content
      else
        messagecontent = content
      end
      local newmessage = message.channel:send({
        embed = messageembed,
        content = messagecontent,
        components = {
          { --whyyyyyy
            type = 1, -- make button container
            components = {
              {
                type = 2, -- make a button
                style = 3, -- green
                label = yesoption, -- add text
                custom_id = etype .. "_yes",
                disabled = "false"
              },
              {
                type = 2, -- make a button
                style = 4, -- red
                label = nooption, -- add text
                custom_id = etype .. "_no",
                disabled = "false"
              }
            }
          } --discord pls
        }
      })
      local tf = dpf.loadjson("savedata/events.json",{})
      local newevent = {ujf = ("savedata/" .. message.author.id .. ".json") ,etype = etype,ogmessage = {channel = {id = message.channel.id}, id = message.id, author = {name=message.author.name, id=message.author.id,mentionString = message.author.mentionString, avatarURL = message.author.avatarURL}}}
      for k,v in pairs(data) do
        newevent[k] = v
      end
      tf[newmessage.id] = newevent
      dpf.savejson("savedata/events.json", tf)
      if not EMULATOR then
        if client:waitFor(newmessage.id, 3600 * 1000) then -- Timeout after 1 hour
          print("Message successfully reacted to, removing event")
        else
          print("Button reaction timed out, removing event")
        end
      
        tf = dpf.loadjson("savedata/events.json",{})
        tf[newmessage.id] = nil
        dpf.savejson("savedata/events.json", tf)
      end

      return newmessage
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
    
    print("handlebutton")
    _G['handlebutton'] = function (buttonid, member, message)
      local ef = dpf.loadjson("savedata/events.json",{})
      if ef[message.id] then
        local reaction = {
          emojiName = "✅",
          message = message
        }
        print("looking for " .. ef[reaction.message.id].etype .. "_no")
        if buttonid == ef[reaction.message.id].etype .. "_no" then
          print("reaction is no")
          reaction.emojiName = "❌"
        end

        local userid = member.id
        print('a button named '.. buttonid .. ' was pressed on a message with the id of ' .. reaction.message.id ..' by a user with the id of' .. userid)
        local eom = ef[reaction.message.id]
        if eom then
          print('it is an event message being reacted to')
          local status, err = pcall(function ()
            cmdre[eom.etype].run(ef, eom, reaction, userid)
          end)
          if not status then
            print("uh oh")
            reaction.message.channel:send("Oops! An error has occured! Error message: ```" .. err .. "``` (<@290582109750427648> <@298722923626364928> please fix this thanks)")
          end
        end
      else
        print("user reacted to a finished button")
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
  
