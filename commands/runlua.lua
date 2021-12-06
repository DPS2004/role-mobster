local command = {}
function command.run(message, mt)
  print("c!runlua!!!!!")
  local cmember = message.guild:getMember(message.author)
  print(mt[1])
  
  local authcheck = false
  for i,v in ipairs(privatestuff.modroles) do
    if cmember:hasRole(v) then
      authcheck = true
    end
  end
  
  if authcheck then
    message.channel:send('Ok, running!')
    local request = table.concat(mt, "/")
    local rfunc = assert(loadstring(request))
    rfunc()
  else
    message.channel:send('Sorry, but only moderators can use this command!')
  end
end
return command
  