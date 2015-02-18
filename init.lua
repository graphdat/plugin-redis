-- [boundary.com] Redis Lua Plugin
-- [author] Ivano Picco <ivano.piccopianobit.com>

-- Requires.
local redis = require('luvit-redis')
local string= require('string')
local split = require('split')

local utils = require('utils')
local uv_native = require ('uv_native')

-- Configuration.
local _param = require ('./param')
_param.pollInterval = (_param.pollInterval>0) and _param.pollInterval or 10000;

-- Client initialization
local client = redis:new(_param.port, _param.host)

client:on("error", function (err)
    utils.debug("Error (error callback): ", err)
end)

if (_param.password) then 
  client:auth(_param.password) 
end

-- Back-trail.
local previousValues={}
local currentValues={}

-- Get difference between current and previous value.
function diffvalues(name)
  local cur  = currentValues[name]
  local last = previousValues[name] or cur
  previousValues[name] = cur
  return  (cur - last)
end

-- Parse line (i.e. line: "connected_clients : <value>").
function parseEachLine(line)
  local t = split(line,':')
  if (#t == 2) then
    currentValues[t[1]]=t[2];
  end
end

-- Get current values.
function poll()
  client:info( function(err,result)
    if (err) then 
      utils.debug(err)
      return
    end
    -- call func with each word in a string
    result:gsub("[^\r\n]+", parseEachLine)
    utils.prettyPrint(currentValues);
    utils.prettyPrint(uv_native.getTotalMemory());
    --outputs
    utils.print('REDIS_CONNECTED_CLIENTS', currentValues.connected_clients, _param.source)
    utils.print('REDIS_KEY_HITS', diffvalues('keyspace_hits'), _param.source)
    utils.print('REDIS_KEY_MISSES', diffvalues('keyspace_misses'), _param.source)
    utils.print('REDIS_KEYS_EXPIRED', diffvalues('expired_keys'), _param.source)
    utils.print('REDIS_KEY_EVICTIONS', diffvalues('evicted_keys'), _param.source)
    utils.print('REDIS_COMMANDS_PROCESSED', diffvalues('total_commands_processed'), _param.source)
    utils.print('REDIS_CONNECTIONS_RECEIVED', diffvalues('total_connections_received'), _param.source)
    utils.print('REDIS_USED_MEMORY', currentValues.used_memory_rss / uv_native.getTotalMemory(), _param.source)
  end)
end

-- Ready, go.
poll()
local timer = require('timer')
timer.setInterval(_param.pollInterval,poll)