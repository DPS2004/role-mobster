local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !roles")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)

  local pagenumber = tonumber(mt[1]) and math.floor(mt[1]) or 1
  pagenumber = math.max(1, pagenumber)

  local numroles = 0
  for k, v in pairs(uj.roles) do
    if v then numroles = numroles + 1 end
  end
  print("Number of roles is " .. numroles)
  local maxpn = math.ceil(numroles / 10)
  pagenumber = math.min(pagenumber, maxpn)

  print("Page number is " .. pagenumber)
  local roletable = {}
  local rolestring = ''

  for k, v in pairs(uj.roles) do
    if v then 
      local eqtext = ""
      if uj.equipped == k then
        eqtext = " (equipped)"
      end
        
      table.insert(roletable, "**" .. k .. "**"..eqtext.."\n")
      
    end
  end
  table.sort(roletable)

  for i = (pagenumber - 1) * 10 + 1, (pagenumber) * 10 do
    print(i)
    if roletable[i] then rolestring = rolestring .. roletable[i] end
  end
  
  message.channel:send{
    content = message.author.mentionString .. ", you have the following roles:",
    embed = {
      color = 0x85c5ff,
      title = message.author.name .. "'s roles",
      description = rolestring,
      footer = {
        text =  "(Page " .. pagenumber .. " of " .. maxpn .. ")",
        icon_url = message.author.avatarURL
      }
    }
  }
end
return command
