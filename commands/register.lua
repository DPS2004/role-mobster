local command = {}
function command.run(message, mt)
  
  
  if io.open("savedata/" .. message.author.id .. ".json", "r+") then
    message.channel:send('You are already registered!')
    return    
  end
  
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)
  local cmember = message.guild:getMember(message.author)
  
  uj = registeruser(cmember,uj)
   
  updateroles(cmember,uj)
  
  
  
  dpf.savejson("savedata/" .. message.author.id .. ".json", uj)
  message.channel:send('Registration complete.')
end
return command
