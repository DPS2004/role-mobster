local command = {}
function command.run(message, mt)
  message.channel:send('ayyy im-a da role mobster, gabagool, paizanos, mama mia, etc')
  print(message.author.name .. " did !ping")
end
return command
  