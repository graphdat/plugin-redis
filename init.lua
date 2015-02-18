-- [boundary.com] Redis Lua Plugin
-- [author] Ivano Picco <ivano.picco@pianobit.com>

-- Requires.
local utils = require('utils')
local uv_native = require ('uv_native')
local string = require('string')
local split = require('split')
local redis = require('luvit-redis')
local timer = require('timer')
local ffi = require ('ffi')
local fs = require('fs')
local json = require('json')

-- portable gethostname syscall
ffi.cdef [[
  int gethostname (char *, int);
]]
function gethostname()
  local buf = ffi.new("uint8_t[?]", 256)
  ffi.C.gethostname(buf,256);
  return ffi.string(buf)
end

-- Configuration.
local _parameters = json.parse(fs.readFileSync('param.json')) or {}

_parameters.pollInterval = 
  (_parameters.pollInterval and tonumber(_parameters.pollInterval)>0  and tonumber(_parameters.pollInterval)) or
  5000;

_parameters.source =
  (type(_parameters.source) == 'string' and _parameters.source:gsub('%s+', '') ~= '' and _parameters.source ~= nil and _parameters.source) or
  gethostname()

-- Client initialization
local client = redis:new(_parameters.port, _parameters.host)

client:on("error", function (err)
  utils.debug("Error (error callback): ", err)
  end)

if (_parameters.password) then 
  client:auth(_parameters.password) 
end

-- Back-trail.
local previousValues={}
local currentValues={}

-- Get difference between current and previous value.
function diffvalues(name)
  local cur  = currentValues[name]
  local last = previousValues[name] or cur
  previousValues[name] = cur
  return  (tonumber(cur) - tonumber(last))
end

-- Parse line (i.e. line: "connected_clients : <value>").
function parseEachLine(line)
  local t = split(line,':')
  if (#t == 2) then
    currentValues[t[1]]=t[2];
  end
end

-- print results
function outputs()
  utils.print('REDIS_CONNECTED_CLIENTS', currentValues.connected_clients, _parameters.source)
  utils.print('REDIS_KEY_HITS', diffvalues('keyspace_hits'), _parameters.source)
  utils.print('REDIS_KEY_MISSES', diffvalues('keyspace_misses'), _parameters.source)
  utils.print('REDIS_KEYS_EXPIRED', diffvalues('expired_keys'), _parameters.source)
  utils.print('REDIS_KEY_EVICTIONS', diffvalues('evicted_keys'), _parameters.source)
  utils.print('REDIS_COMMANDS_PROCESSED', diffvalues('total_commands_processed'), _parameters.source)
  utils.print('REDIS_CONNECTIONS_RECEIVED', diffvalues('total_connections_received'), _parameters.source)
  utils.print('REDIS_USED_MEMORY', currentValues.used_memory_rss / uv_native.getTotalMemory(), _parameters.source)
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

      outputs()
    end)
end

-- Ready, go.
poll()
timer.setInterval(_parameters.pollInterval,poll)