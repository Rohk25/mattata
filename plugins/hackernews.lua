--[[
    Based on a plugin by topkecleon.
    Copyright 2017 wrxck <matthew@matthewhesketh.com>
    This code is licensed under the MIT. See LICENSE for details.
]]--

local hackernews = {}

local mattata = require('mattata')
local https = require('ssl.https')
local json = require('dkjson')

function hackernews:init(configuration)
    hackernews.arguments = 'hackernews'
    hackernews.commands = mattata.commands(
        self.info.username,
        configuration.command_prefix
    ):command('hackernews'):command('hn').table
    hackernews.help = '/hackernews - Sends the top stories from Hacker News. Alias: /hn.'
end

function hackernews.get_results(hackernews_topstories, hackernews_result, hackernews_article)
    local results = {}
    local jstr, res = https.request(hackernews_topstories)
    if res ~= 200 then
        return false
    end
    local jdat = json.decode(jstr)
    for i = 1, 8 do
        local result_jstr, result_res = https.request(hackernews_result:format(jdat[i]))
        if result_res ~= 200 then
            return false
        end
        local result_jdat = json.decode(result_jstr)
        local result
        if result_jdat.url then
            result = string.format(
                '\n• <code>[</code><a href="%s">%s</a><code>]</code> <a href="%s">%s</a>',
                mattata.escape_html(hackernews_article:format(result_jdat.id)),
                result_jdat.id,
                mattata.escape_html(result_jdat.url),
                mattata.escape_html(result_jdat.title)
            )
        else
            result = string.format(
                '\n• <code>[</code><a href="%s">%s</a><code>]</code> %s',
                mattata.escape_html(hackernews_article:format(result_jdat.id)),
                result_jdat.id,
                mattata.escape_html(result_jdat.title)
            )
        end
        table.insert(
            results,
            result
        )
    end
    return results
end

function hackernews:on_message(message, configuration, language)
    local results = hackernews.get_results('https://hacker-news.firebaseio.com/v0/topstories.json', 'https://hacker-news.firebaseio.com/v0/item/%s.json', 'https://news.ycombinator.com/item?id=%s')
    if not results then
        return mattata.send_reply(
            message,
            language.errors.connection
        )
    end
    local result_count = message.chat.id == message.from.id and 8 or 4
    local output = '<b>Top Stories from Hacker News:</b>'
    for i = 1, result_count do
        output = output .. results[i]
    end
    mattata.send_chat_action(
        message.chat.id,
        'typing'
    )
    return mattata.send_message(
        message.chat.id,
        output,
        'html'
    )
end

return hackernews