local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !roles")
  
  
  
  local pagenumber = tonumber(mt[1]) and math.floor(mt[1]) or 1
  pagenumber = math.max(1, pagenumber)

  local numroles = 0
  for k, v in pairs(roles.list) do
    numroles = numroles + 1
  end
  print("Number of roles is " .. numroles)
  local maxpn = math.ceil(numroles / 10)
  pagenumber = math.min(pagenumber, maxpn)

  print("Page number is " .. pagenumber)
  local roletable = {}
  local rolestring = ''

  for k, v in pairs(roles.list) do


        
      table.insert(roletable, "**" .. k .. "**\n")

  end
  table.sort(roletable)

  for i = (pagenumber - 1) * 10 + 1, (pagenumber) * 10 do
    print(i)
    if roletable[i] then rolestring = rolestring .. roletable[i] end
  end
  
  message.channel:send{
    content = message.author.mentionString .. ", the following roles are on this server:",
    embed = {
      color = 0x85c5ff,
      title = "",
      description = rolestring,
      footer = {
        text =  "(Page " .. pagenumber .. " of " .. maxpn .. ")",
        icon_url = message.author.avatarURL
      }
    }
  }
end
return command
