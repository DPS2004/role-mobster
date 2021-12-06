_G["discordia"] = require('discordia')
_G["client"] = discordia.Client()
_G["prefix"] = "r!"
_G["json"] = require('libs/json')
_G["fs"] = require('fs')
_G["dpf"] = require('libs/dpf')
_G["inspect"] = require('libs/inspect')
_G["http"] = require('coro-http')

--137909095424

-- load all the extensions
discordia.extensions()

-- import all the commands
_G['cmd'] = {}
-- import reaction commands
_G['cmdre'] = {}

_G['cmdcons'] = {}

_G['tr'] = {}
local rdb = dofile('commands/reloaddb.lua')
rdb.run(nil,nil,true)
print("exited rdb.run")

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)
print("yay got past load ready")

client:on('messageCreate', function(message)
  handlemessage(message)
end)

client:run(privatestuff.botid)

client:setGame("ayyy im-a da role mobster")