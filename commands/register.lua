local command = {}
function command.run(message, mt)
  
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)
  local cmember = message.guild:getMember(message.author)
  
  if inspect(uj) ~= inspect(defaultjson) then
    message.channel:send('You are already registered!')
    return
  end
  
  for k,v in pairs(roles.list) do
    if cmember:hasRole(v.id) then
      uj.roles[k] = true
      if v.subroles then
        for i,s in ipairs(v.subroles) do
          uj.roles[s] = true
          
        end
      end
    end
    
  end
  updateroles(cmember,uj)
  
  
  
  dpf.savejson("savedata/" .. message.author.id .. ".json", uj)
  message.channel:send('Registration complete.')
end
return command
