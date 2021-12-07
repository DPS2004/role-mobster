local command = {}
function command.run(message, mt)
  
  local authcheck = false
  local cmember = message.guild:getMember(message.author)
  for i,v in ipairs(privatestuff.modroles) do

    if cmember:hasRole(v) then
      authcheck = true
    end
  end
  if not authcheck then
    message.channel:send('Sorry, but only moderators can use this command!')
    return
  end
  
  
  local giveuserid = mentiontoid(mt[1])
  if not giveuserid then
    message.channel:send("That is not a user I can give a role to!")
    return
  end
  local giveuser = message.guild:getMember(giveuserid)
  local uj = nil
  
  if io.open("savedata/" .. giveuserid .. ".json", "r+") == nil then
    uj = dpf.loadjson("savedata/" .. giveuserid .. ".json",defaultjson)
    uj = registeruser(giveuser,uj)
    updateroles(giveuser,uj)
    dpf.savejson("savedata/" .. giveuserid .. ".json", uj)
  else
    uj = dpf.loadjson("savedata/" .. giveuserid .. ".json",defaultjson)
  end
  
  local request = ""
  --properly capitalize the request
  for k,v in pairs(roles.list) do
    if string.lower(k) == string.lower(mt[2]) then
      request = k
    end
  end
  
  if request == "" then
    message.channel:send('I could not find a role called "'..mt[2]..'" in the database. Make sure you spelled it right!')
    return
  end
  
  uj.roles[request] = true
  
  local srtext = ""
  
  if roles.list[request].subroles then
    for i,v in ipairs(roles.list[request].subroles) do
      uj.roles[v] = true
    end
    srtext = ", as well as some subroles"
  end
  
  message.channel:send("Ok, **".. request .."** has been given to the user"..srtext.."!")
  
  
  
  dpf.savejson("savedata/" .. message.author.id .. ".json", uj)
end
return command
