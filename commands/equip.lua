local command = {}
function command.run(message, mt)
  
  local uj = nil
  local cmember = message.guild:getMember(message.author)
  if io.open("savedata/" .. message.author.id .. ".json", "r+") == nil then
    uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)
    uj = registeruser(cmember,uj)
    updateroles(cmember,uj)
    dpf.savejson("savedata/" .. message.author.id .. ".json", uj)
  else
    uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)
  end
  
  local request = ""
  
  --properly capitalize the request
  for k,v in pairs(roles.list) do
    if string.lower(k) == string.lower(mt[1]) then
      request = k
    end
  end
  
  if request == "" then
    message.channel:send('I could not find a role called "'..mt[1]..'" in the database. Make sure you spelled it right!')
    return
  end
  if not uj.roles[request] then
    message.channel:send("Sorry, but you don't have the **" .. request.. "** role. You can view a list of the roles you have with `r!roles`.")
    return
  end
  if uj.equipped == request then
    message.channel:send("You already have that role equipped!")
    return
  end
  
  uj.equipped = request
  updateroles(cmember,uj)
  message.channel:send("Ok, **".. request .."** is now your equipped role!")
  
  
  
  dpf.savejson("savedata/" .. message.author.id .. ".json", uj)
end
return command
