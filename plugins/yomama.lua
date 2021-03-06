--[[
    Copyright 2017 wrxck <matthew@matthewhesketh.com>
    This code is licensed under the MIT. See LICENSE for details.
]]--

local yomama = {}

local mattata = require('mattata')
local http = require('socket.http')
local json = require('dkjson')

function yomama:init(configuration)
    yomama.arguments = 'yomama'
    yomama.commands = mattata.commands(
        self.info.username,
        configuration.command_prefix
    ):command('yomama').table
    yomama.help = '/yomama - Tells a Yo\' Mama joke!'
end

function yomama:on_message(message, configuration, language)
    local jstr, res = http.request('http://api.yomomma.info/')
    if res ~= 200 then
        return mattata.send_reply(
            message,
            language.errors.connection
        )
    end
    if jstr:match('^Unable to connect to the da?t?a?ba?s?e? server%.?$') then
        return mattata.send_reply(
            message,
            language.errors.results
        )
    end
    local jdat = json.decode(jstr)
    return mattata.send_message(
        message.chat.id,
        jdat.joke
    )
end

return yomama