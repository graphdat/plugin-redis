local redis = require('luvit-redis')
local string= require('string')
local split = require('split')
local boundary = require('boundary')

local utils = require('utils')
local uv_native = require ('uv_native')

local pollInterval = 10000
local port         = 6379
local host         = "localhost"
local source       = nil

if (boundary.param ~= nil) then
  pollInterval = (boundary.param.pollInterval>0) and boundary.param.pollInterval or pollInterval
  source       = (type(boundary.param.source) == 'string' and boundary.param.source:gsub('%s+', '') ~= '' and boundary.param.source) or
   io.popen("uname -n"):read('*line')
  host       = (type(boundary.param.host) == 'string' and boundary.param.host:gsub('%s+', '') ~= '' and boundary.param.host) or host
  port = (boundary.param.port>0) and boundary.param.port or port
end

local client = redis:new(port, host)

client:on("error", function (err)
    utils.debug("Error (error callback): ", err)
end)

if (boundary.param.password) then 
  client:auth(boundary.param.password) 
end

local previousValues={}
local currentValues={}
function diffvalues(name)
  local cur  = currentValues[name]
  local last = previousValues[name] or cur
  previousValues[name] = cur
  return  (cur - last)
end

function parseEachLine(line)
  local t = split(line,':')
  if (#t == 2) then
    currentValues[t[1]]=t[2];
  end
end

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
    utils.print('REDIS_CONNECTED_CLIENTS', currentValues.connected_clients, boundary.param.source)
    utils.print('REDIS_KEY_HITS', diffvalues('keyspace_hits'), boundary.param.source)
    utils.print('REDIS_KEY_MISSES', diffvalues('keyspace_misses'), boundary.param.source)
    utils.print('REDIS_KEYS_EXPIRED', diffvalues('expired_keys'), boundary.param.source)
    utils.print('REDIS_KEY_EVICTIONS', diffvalues('evicted_keys'), boundary.param.source)
    utils.print('REDIS_COMMANDS_PROCESSED', diffvalues('total_commands_processed'), boundary.param.source)
    utils.print('REDIS_CONNECTIONS_RECEIVED', diffvalues('total_connections_received'), boundary.param.source)
    utils.print('REDIS_USED_MEMORY', currentValues.used_memory_rss / uv_native.getTotalMemory(), boundary.param.source)
  end)
end

poll()
local timer = require('timer')
timer.setInterval(pollInterval,poll)
